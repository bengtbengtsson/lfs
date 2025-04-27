#!/bin/bash

echo "Noting to do here. This script mainly for documentation."
exit 1


# Generate a new user 'lfs'
# groupadd lfs
# useradd -m -s /bin/bash -g lfs lfs
#
# Set password
# passwd lfs
#
# Set sudo access
# usermod -aG wheel lfs
#
# Modify sudo config file 
# visudo
# %wheel ALL=(ALL) ALL # remove the '#' from beginning of line
#
# Test it 
# su - lfs
# sudo whoami
# Above should return 'root'
#
# Generate a simple .bash_profile
# # ~/.bash_profile
#
# Source the user's bashrc if it exists
#if [ -f ~/.bashrc ]; then
#    . ~/.bashrc
#fi
#
#
# Generate a simple .bashrc
# # ~/.bashrc

# Set a colorful and informative prompt
# PS1='\u@\h:\w\$ '

# Useful aliases
# alias ll='ls -l --color=auto'
# alias la='ls -la --color=auto'
# alias grep='grep --color=auto'

# Editor and pager
# export EDITOR=vim
# export PAGER=less

# Enable command history
# HISTSIZE=1000
# HISTFILESIZE=2000

# Export CA path for curl, git and cmake (since you're using certs manually)
# export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
# export GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt
# export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

