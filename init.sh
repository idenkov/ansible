#!/bin/bash
sudo apt install ansible ssh sshpass
echo -e "\033[0;33mPlease run your role with "ansible-playbook {role}.yml -K -b"\033[0;33m"
