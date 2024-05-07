#!/bin/bash
sudo apt install ansible ssh sshpass
git submodule update --init
echo -e "\033[0;33mPlease run your role with "ansible-playbook {role}.yml -K -k -b --ask-vault-password"\033[0;33m"
