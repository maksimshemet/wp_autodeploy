#!/bin/bash

apt-add-repository ppa:ansible/ansible
apt update
apt install ansible -y

mkdir /tmp/ansible

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

EOT

cd /tmp/ansible

ansible-playbook lamp.yaml