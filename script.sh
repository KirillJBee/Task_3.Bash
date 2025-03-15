#!/bin/bash

#Переменные скрипта

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

#Настройки окружения фронтэнд
PORT_API="80"
PROTOCOL="http"


   echo "Проверяем наличие  PostgreSQL..."
    if psql -V 2>/dev/null | grep -q "PostgreSQL"; then
        echo "$(psql -V) уже установлен."
    else
        echo "Устанавливаем PostgreSQL ..."
        sudo apt update
        sudo apt install -y curl ca-certificates gnupg

        # Import the repository signing key:
        sudo install -d /usr/share/postgresql-common/pgdg
        sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc

        # Create the repository configuration file:
        sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

        # Update the package lists:
        sudo apt update

        # Install the latest version of PostgreSQL:
        #If you want a specific version, use 'postgresql-16' or similar instead of 'postgresql'
        sudo apt -y install postgresql-$PG_VERSION
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
    sudo -u postgres psql -U postgres -d java_db <<EOF
    GRANT ALL ON SCHEMA public TO $DB_USER ;
    GRANT CREATE ON SCHEMA public TO $DB_USER;
    ALTER SCHEMA public OWNER TO $DB_USER;
EOF
   echo "Права доступа к схеме Public пользователя $DB_USER успешно созданы."

    echo "Проверяем наличие Nginx ..."
     if nginx -v 2>&1 | grep -q "nginx version"; then
        echo "$(nginx -v) уже установлен."
     else
        echo "Устанавливаем Nginx ..."
        #sudo apt update
        sudo apt install -y nginx
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
        sudo apt install -y redis-server
        sudo systemctl start redis.service
        echo "Redis-server установлен."
      fi

    echo "Проверяем наличие  Java OpenJDK..."
      if  java -version 2>&1 | grep -q "openjdk version"; then
        echo "$(java -version) уже установлен."
      else
        echo "Устанавливаем Java OpenJDK ..."
        #sudo apt update
        sudo apt install -y openjdk-$JAVA_VERSION_JDK-jdk
        #sudo systemctl start redis.service
        echo "Java OpenJDK установлен."
      fi

    echo "Проверяем наличие  Gradle..."
      if  gradle -v | grep -q "$GRADLE_VERSION"; then
        echo "$(gradle -v) уже установлен."
      else
        if [ -e "gradle-$GRADLE_VERSION-all.zip" ]; then
           sudo mkdir /opt/gradle
           sudo unzip -d /opt/gradle gradle-$GRADLE_VERSION-all.zip
           echo "export PATH=$PATH:/opt/gradle/gradle-$GRADLE_VERSION/bin" >> ~/.bashrc
           source ~/.bashrc
           echo "Устанавливаем Gradle $GRADLE_VERSION ..."
      else
        #sudo apt update
        wget https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-all.zip
        sudo mkdir /opt/gradle
        sudo unzip -d /opt/gradle gradle-$GRADLE_VERSION-all.zip
        echo "export PATH=$PATH:/opt/gradle/gradle-$GRADLE_VERSION/bin" >> ~/.bashrc
        source ~/.bashrc
        #sudo systemctl start redis.service
        echo "Gradle $GRADLE_VERSION установлен."
        fi
      fi

    echo "Проверяем наличие  NodeJS..."
      if  node -v | grep -q "v22.9.0"; then
        echo "NodeJS $(node -v) уже установлен."
      else
        echo "Устанавливаем NodeJS $NODE_VERSION ..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
        source ~/.bashrc
        nvm install $NODE_VERSION
        echo "Gradle $GRADLE_VERSION установлен."
      fi
    
    #Продумать выгрузку настроить if
    echo "Выгрузка репозитория"
      if [ -e "$DIR_APP" ]; then
        echo "Репозиторий уже существует"
      else
        git clone $REPOSITORY $DIR_APP
      fi


    #Корректируем .env файла для фронтенда

    IP=$(hostname -I | awk '{print $2}')
    #Устанавливаем значение REACT_APP_API_URL в файле .env
    sed -i "s|^REACT_APP_API_URL=.*|REACT_APP_API_URL=http://$IP|" $DIR_APP/front-end/.env
    #Устанавливаем значение REACT_APP_API_PORT в файле .env
    sed -i "s|^REACT_APP_API_PORT=.*|REACT_APP_API_PORT=$PORT_API|" $DIR_APP/front-end/.env

    echo "Файл .env обновлен: REACT_APP_API_URL=http://$IP  REACT_APP_API_PORT=$PORT_API"
    
    #Корректируем .env файла для бэкэнда

    IP=$(hostname -I | awk '{print $2}')
    #Устанавливаем значение REACT_APP_API_URL в файле .env
    sed -i "s|^REACT_APP_API_URL=.*|REACT_APP_API_URL=$PROTOCOL://$IP|" $DIR_APP/front-end/.env
    #Устанавливаем значение REACT_APP_API_PORT в файле .env
    sed -i "s|^REACT_APP_API_PORT=.*|REACT_APP_API_PORT=$PORT_API|" $DIR_APP/front-end/.env

    echo "Файл .env обновлен: REACT_APP_API_URL=$PROTOCOL://$IP  REACT_APP_API_PORT=$PORT_API"



    echo "Сборка и старт front-end side"
      cd $DIR_APP/front-end && npm install && npm run build
      sudo mkdir -p /var/www/linuxwebserver
      sudo cp -r build/* /var/www/linuxwebserver
      sudo cp ~/$DIR_APP/configNginx80 /etc/nginx/sites-available/default 
      sudo nginx -s reload

    echo "Сборка и старт front-back"
      cd ~/$DIR_APP/back-end && gradle bootJar
      env $(cat .env | xargs) java -jar build/libs/ci-back-end-0.0.1-SNAPSHOT.jar

    echo "Экспорт базы данных примеров постов"
      export PGPASSWORD="$DB_PASSWORD" && psql -U $DB_USER -h localhost -d $DB_NAME -f $DB_BACKUP 2 > /dev/null
      

    

