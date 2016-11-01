#!/bin/sh
set -e
# X forward version

#Docker
#clean pid after unexpected kill
if [ -f "/var/run/docker.pid" ]; then
		rm -rf /var/run/docker.pid
fi

if [ "$#" -eq 0 -o "${1:0:1}" = '-' ]; then
	set -- docker daemon \
		--host=unix:///var/run/docker.sock \
		--host=tcp://127.0.0.1:2375 \
		--storage-driver=overlay \
		"$@"
fi

if [ "$1" = 'docker' -a "$2" = 'daemon' ]; then
	# if we're running Docker, let's pipe through dind
	# (and we'll run dind explicitly with "sh" since its shebang is /bin/bash)
	set -- sh "$(which dind)" "$@"
fi

#Xorg
# prepare for X forwarding
#prepare xauth
touch /root/.Xauthority

# generate machine-id
uuidgen > /etc/machine-id

#SSHD / X related

# prepare keys
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	# generate fresh rsa key
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
	# generate fresh dsa key
	ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi
#prepare run dir
if [ ! -d "/var/run/sshd" ]; then
	mkdir -p /var/run/sshd
fi
#prepare sshd config for X
if [ -f "/etc/ssh/sshd_config" ]; then
	sed -i "s/#X11Forwarding no/X11Forwarding yes/g" /etc/ssh/sshd_config
fi
#prepare ssh config for X
if [ -f "/etc/ssh/ssh_config" ]; then
	sed -i "s/#X11Forwarding no/X11Forwarding yes/g" /etc/ssh/ssh_config
	echo "ForwardX11Trusted yes" >> /etc/ssh/ssh_config
fi
# reread all config
source /etc/profile
# start sshd
/usr/sbin/sshd -D &

# set docker settings
echo "export DOCKER_HOST='tcp://127.0.0.1:2375'" >> /etc/profile
# reread all config
source /etc/profile

exec "$@"
