# ~/.bashrc

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set a nicer prompt
PS1='\u@\h \w\$ '

# Useful aliases
alias ll='ls -l --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

# Export common env vars
export EDITOR=vim
export HISTSIZE=1000
export HISTFILESIZE=2000

# Use system-wide CA certs with curl
export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

