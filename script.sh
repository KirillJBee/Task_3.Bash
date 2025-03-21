#!/bin/bash

#Перменные для инсталляции окружения
PG_VERSION="17"
JAVA_VERSION_JDK="21"
GRADLE_VERSION="8.5"
NODE_VERSION="22.9.0"
REPOSITORY="https://github.com/KirillJBee/Task_3.LinuxWebServer.git"
DIR_APP="LinuxWebServer"


#Перменные для настройки базы данных и .env бэкэнда
DB_USER="java_user"
DB_PASSWORD="12345"
DB_NAME="java_db"
DB_BACKUP="sample_db.sql"
DB_HOST="localhost"
DB_PORT="5432"

#Настройки окружения фронтэнд
PORT_API="443"
PROTOCOL="https"
SERVER_PORT="8081"

# Параметры для самоподписанного сертификата TLS
DOMAIN="linuxwebserver.com"
DAYS=365
OUTPUT_DIR="/etc/nginx/ssl"
KEY_FILE="$OUTPUT_DIR/$DOMAIN.key"
CSR_FILE="$OUTPUT_DIR/$DOMAIN.csr"
CRT_FILE="$OUTPUT_DIR/$DOMAIN.crt"

#Конфигурация сервера
echo "Проверяем наличие  PostgreSQL..."
  if psql -V 2>/dev/null | grep -q "PostgreSQL"; then
    echo "$(psql -V) уже установлен."
  else
    echo "Устанавливаем PostgreSQL ..."
    sudo apt-get -qq update
    sudo apt-get -qq install -y curl ca-certificates gnupg

    # Импорт ключа репозитория:
    sudo install -d /usr/share/postgresql-common/pgdg
    sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc

    # СОздание конфигурации репозитория:
    sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

    # Обновдение базы репозиториев:
    sudo apt-get -qq update

    # Install the latest version of PostgreSQL:
    #If you want a specific version, use 'postgresql-16' or similar instead of 'postgresql'
    sudo apt-get -qq install -y postgresql-$PG_VERSION >> $HOME/output.log
    sudo systemctl start postgresql
    echo "PostgreSQL $PG_VERSION установлен."
  fi
   
echo "Создание базы и пользователя PostgreSQL..."
sudo -u postgres psql <<EOF
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
CREATE DATABASE $DB_NAME OWNER $DB_USER;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
EOF
echo "Пользователь $DB_USER и база данных $DB_NAME успешно созданы."

echo "Настройка прав доступа к схеме Public пользователя $DB_USER"
sudo -u postgres psql -U postgres -d $DB_NAME <<EOF
GRANT ALL ON SCHEMA public TO $DB_USER;
GRANT CREATE ON SCHEMA public TO $DB_USER;
ALTER SCHEMA public OWNER TO $DB_USER;
EOF
   echo "Права доступа к схеме Public пользователя $DB_USER успешно созданы."
    
echo "Экспорт базы данных примеров постов"
export PGPASSWORD="$DB_PASSWORD" && psql -U $DB_USER -h localhost -d $DB_NAME -f $HOME/$DB_BACKUP >> $HOME/output.log 2>> $HOME/error.log


echo "Проверяем наличие Nginx ..."
  if nginx -v 2>&1 | grep -q "nginx version"; then
    echo "$(nginx -v) уже установлен."
  else
    echo "Устанавливаем Nginx ..."
    #sudo apt update
    sudo apt-get -qq install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
    echo "Nginx установлен."
    fi

echo "Проверяем наличие  Redis..."
  if redis-server -v 2>/dev/null | grep -q "Redis server"; then
    echo "$(redis-server -v) уже установлен."
  else
    echo "Устанавливаем Redis ..."
    #sudo apt update
    sudo apt-get -qq install -y redis-server
    sudo systemctl start redis.service
    echo "Redis-server установлен."
  fi

echo "Проверяем наличие  Java OpenJDK..."
  if java -version 2>&1 | grep -q "openjdk version"; then
    echo "$(java -version) уже установлен."
  else
    echo "Устанавливаем Java OpenJDK ..."
    sudo apt-get -qq install -y openjdk-$JAVA_VERSION_JDK-jdk >> $HOME/output.log
    echo "Java OpenJDK установлен."
  fi

echo "Проверяем наличие  Gradle..."
  if gradle -v | grep -q "$GRADLE_VERSION"; then
      echo "$(gradle -v) уже установлен."
  else
    if [ -e "gradle-$GRADLE_VERSION-all.zip" ]; then
      sudo mkdir /opt/gradle
      sudo unzip -d /opt/gradle gradle-$GRADLE_VERSION-all.zip >> $HOME/output.log
      echo "export PATH=$PATH:/opt/gradle/gradle-$GRADLE_VERSION/bin" >> $HOME/.bashrc
      source $HOME/.bashrc
      echo "Устанавливаем Gradle $GRADLE_VERSION ..."
  else
    wget https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-all.zip
    sudo mkdir /opt/gradle
    sudo unzip -d /opt/gradle gradle-$GRADLE_VERSION-all.zip > /dev/null
    echo "export PATH=$PATH:/opt/gradle/gradle-$GRADLE_VERSION/bin" >> $HOME/.bashrc
    source $HOME/.bashrc
      echo "Gradle $GRADLE_VERSION установлен."
    fi
  fi

echo "Проверяем наличие  NodeJS..."
  if node -v | grep -q "v22.9.0"; then
      echo "NodeJS $(node -v) уже установлен."
  else
    echo "Устанавливаем NodeJS $NODE_VERSION ..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
    source $HOME/.bashrc
    nvm install $NODE_VERSION >> $HOME/output.log
    echo "NodeJS $NODE_VERSION установлен."
  fi
    
#Продумать выгрузку настроить if
echo "Выгрузка репозитория"
  if [ -e "$DIR_APP" ]; then
    echo "Репозиторий уже существует"
  else
    git clone $REPOSITORY $DIR_APP
  fi

#Корректируем .env файла для фронтенда
echo "Корректируем .env файла для фронтенда"
IP=$(hostname -I | awk '{print $2}')
#Устанавливаем значение REACT_APP_API_URL в файле .env
sed -i "s|^REACT_APP_API_URL=.*|REACT_APP_API_URL=$PROTOCOL://$DOMAIN|" $DIR_APP/front-end/.env $DOMAIN
#Устанавливаем значение REACT_APP_API_PORT в файле .env
sed -i "s|^REACT_APP_API_PORT=.*|REACT_APP_API_PORT=$PORT_API|" $DIR_APP/front-end/.env

echo "Файл .env обновлен: REACT_APP_API_URL=$PROTOCOL://$IP  REACT_APP_API_PORT=$PORT_API"
    
#Корректируем .env файла для бэкэнда
echo "Корректируем .env файла для бэкенда"

sed -i "s|^POSTGRES_HOST=.*|POSTGRES_HOST=$DB_HOST|" $HOME/$DIR_APP/back-end/.env

sed -i "s|^POSTGRES_PORT=.*|POSTGRES_PORT=$DB_PORT|" $HOME/$DIR_APP/back-end/.env

sed -i "s|^POSTGRES_USER=.*|POSTGRES_USER=$DB_USER|" $HOME/$DIR_APP/back-end/.env

sed -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$DB_PASSWORD|" $HOME/$DIR_APP/back-end/.env

sed -i "s|^POSTGRES_DB=.*|POSTGRES_DB=$DB_NAME|" $HOME/$DIR_APP/back-end/.env

sed -i "s|^SERVER_PORT=.*|SERVER_PORT=$SERVER_PORT|" $HOME/$DIR_APP/back-end/.env

echo "Файл .env обновлен"

#Сборка и старт front-end side
echo "Сборка и старт front-end side"
cd $HOME/$DIR_APP/front-end && npm install >> $HOME/output.log 2>> error.log
cd $HOME/$DIR_APP/front-end && npm run build >> $HOME/output.log 2>> error.log
sudo mkdir -p /var/www/$DOMAIN
sudo cp -r build/* /var/www/$DOMAIN

#Настройка конфигурации сервера Nginx, создание самоподписанного сертифката

sudo mkdir -p "/etc/nginx/ssl"

# Генерация приватного ключа
sudo openssl genpkey -algorithm RSA -out "$KEY_FILE"

# Генерация CSR (Certificate Signing Request)
sudo openssl req -new -key "$KEY_FILE" -out "$CSR_FILE" -subj "/CN=$DOMAIN" 

# Генерация самоподписанного сертификата
sudo openssl x509 -req -days "$DAYS" -in "$CSR_FILE" -signkey "$KEY_FILE" -out "$CRT_FILE" 

# Удаляем CSR файл, так как он больше не нужен
sudo rm "$CSR_FILE"

echo "Самоподписанный сертификат для $DOMAIN создан в $OUTPUT_DIR"

sudo cp $HOME/$DIR_APP/configNginx443 /etc/nginx/sites-available/default 
sudo nginx -s reload

#Сборка back-end side
echo "Сборка back-end side"
cd $HOME/$DIR_APP/back-end && gradle bootJar >> $HOME/output.log  2>> $HOME/error.log

#Старт back-end side
echo "Старт back-end side"
env $(cat .env | xargs) java -jar $HOME/$DIR_APP/back-end/build/libs/ci-back-end-0.0.1-SNAPSHOT.jar >> $HOME/output.log  2>> $HOME/error.log &
cd

#Настройка Firewall
echo "Настройка firewall"

sudo ufw allow 80/tcp && sudo ufw allow 22/tcp && sudo ufw allow 443/tcp 

# Включаем UFW без запроса подтверждения
echo "y" | sudo ufw enable

echo "Текущее состояние Firewall: $(sudo ufw status verbose)"

echo "Проверить работоспособность приложения можно по адресу $PROTOCOL://$IP или $PROTOCOL://$DOMAIN"
