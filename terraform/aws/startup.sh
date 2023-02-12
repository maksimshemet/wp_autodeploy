#!/bin/bash

apt-add-repository ppa:ansible/ansible
apt update
apt install ansible -y

mkdir /tmp/ansible
mkdir /tmp/scripts

cat <<EOT >> /tmp/scripts/download_WP.sh
#!/bin/bash

while [ "\$#" -gt 0 ]; do
  case "\$1" in
    -v|--version)
      wp_version="\$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: \$1"
      exit 1
      ;;
  esac
done

# Define the target directory
TARGET_DIR="/var/www/html"
if [ ! -d "\$TARGET_DIR" ]; then
  mkdir "\$TARGET_DIR"
fi


# Define wordpress url
WP_VERSION="wordpress-\$wp_version"
WP_URL="https://wordpress.org/\$WP_VERSION.tar.gz"

# Download the latest version of WordPress
curl -L \$WP_URL -o \$WP_VERSION.tar.gz

# Unpack the WordPress archive
tar xzf \$WP_VERSION.tar.gz

# Remove the archive
rm \$WP_VERSION.tar.gz

# Move the contents of the WordPress directory to the target directory
if [ -d "\$TARGET_DIR" ]; then
  rm -rf "\$TARGET_DIR"
fi
mv wordpress "\$TARGET_DIR"

echo "WordPress has been successfully downloaded and unpacked into \$TARGET_DIR"

EOT

cat <<EOT >> /tmp/ansible/lamp.yaml
---
- name: LAMP Stack Playbook
  hosts: localhost
  connection: local
  become: yes
  tasks:
    - name: Install Apache Web Server
      apt:
        name: apache2
        state: present

    - name: Start and Enable Apache Service
      service:
        name: apache2
        state: started
        enabled: yes

    - name: Install PHP and Required Libraries
      apt:
        name: "{{ packages }}"
        state: present
      vars:
        packages:
          - php
          - libapache2-mod-php
          - php-mysql
          - php-curl
          - php-gd
          - php-mbstring
          - php-xml
          - php-xmlrpc

    - name: Install MySQL Server
      apt:
        name: mysql-server
        state: present

    - name: Start and Enable MySQL Service
      service:
        name: mysql
        state: started
        enabled: yes
    - name: Download and mv wordpress
      script: /tmp/scripts/download_WP.sh --version 6.1.1
EOT

cd /tmp/ansible

ansible-playbook lamp.yaml