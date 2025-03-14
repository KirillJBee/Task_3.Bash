Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.vm.box = "ubuntu/jammy64"
    config.vm.hostname = "linuxwebserver"
    config.vm.boot_timeout = 30
    config.vm.network "public_network", ip: "192.168.1.222",  bridge: "wlp1s0"
    #config.vm.synced_folder ".", "/vagrant", disabled: true
    
    config.vm.provider "virtualbox" do |vb|
        vb.memory = 4096
        vb.name = "Task_3.Bash"
    end

    # Создание пользователя "user" с домашней директорией и оболочкой Bash
    config.vm.provision "shell", inline: <<-SHELL
    sudo useradd -m -s /bin/bash user
    echo "user:123" | sudo chpasswd
    sudo usermod -aG sudo user
    echo "user ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/user
    SHELL
    
    # Добавление SSH-ключа для пользователя 'user'
    config.vm.provision "shell", inline: <<-SHELL
    sudo mkdir -p /home/user/.ssh
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYr423a9ByX9kAqD5OcukDT3kz6dmrCdid9Nn/gmPpv" >> /home/user/.ssh/authorized_keys
    sudo chmod 700 /home/user/.ssh
    sudo chmod 600 /home/user/.ssh/authorized_keys
    sudo chown -R user:user /home/user/.ssh
    SHELL

    # Инсталляция файлового менеджера MC
    config.vm.provision "shell", inline: <<-SHELL
    sudo apt update && sudo apt -y upgrade
    sudo apt install -y mc
    SHELL

    # Перенос скачаного архива gradle-8.5-all.zip для ускорения процесса инсталляции :-)
    config.vm.provision "shell", inline: <<-SHELL
    cp /vagrant/*.zip /home/user
    SHELL
end
