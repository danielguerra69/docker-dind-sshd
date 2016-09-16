# About this Repo

This repo is based on the official git repo from docker.
I added sshd,git and docker-compose to docker-dind.
Result a ssh server with behind it a complete docker server.
On top of it you can use the xorg tag for ssh X forwarding.

# Key based usage (prefered)

Copy the id_rsa.pub from your workstation to your dockerhost.
On the dockerhost create a volume to keep your authorized_keys.
```bash
tar cv --files-from /dev/null | docker import - scratch
docker create -v /root/.ssh --name ssh-container scratch /bin/true
docker cp id_rsa.pub ssh-container:/root/.ssh/authorized_keys
```

For ssh key forwarding use ssh-agent on your workstation.
```bash
ssh-agent
ssh-add id_rsa
```

Then the start sshd service on the dockerhost
```bash
docker run -p 4848:22 --privileged --name docker-sshd --hostname docker-sshd --volumes-from ssh-container  -d danielguerra/docker-dind-sshd
```

# Password based

```bash
docker run -p 4848:22 --privileged --name docker-sshd --hostname docker-sshd -d danielguerra/docker-dind-sshd
docker exec -ti docker-sshd passwd
```

# From your workstation

ssh to your new docker environment
```bash
ssh -p 4848 -i id_rsa root@<dockerhost>
```

# Inside the new docker host

```bash
docker ps
docker run -ti alpine /bin/sh (Ctrl d)
wget http://docker-compose.org/docker-compose-yml
docker-compose up
```

# X11 the xorg tag

The xorg tag is made for X forwarding.
Start a local X-server. On mac you can use XQuartz.
Ssh into the container and run your favorite alpine
x-app (e.g. firefox) and see it on your local machine.

Start the xorg container
```bash
docker run -p 4848:22 --privileged --name docker-sshd --hostname docker-sshd --volumes-from ssh-container  -d danielguerra/docker-dind-sshd:xorg
```

After this from your linux
X environment or from the Xquartz
terminal. See note Xquartz

ssh to your new container
```bash
ssh -i id_rsa -p 4848 -X root@<dockerhost>
```

# Xquartz note

For cmd+v cmd+c e.g. copy/paste to work you need to do this on your mac.
```bash
cd ~/
vi .Xdefaults
```

paste this line (without the quotes)

`*VT100.translations: #override  Meta <KeyPress> V:  insert-selection(PRIMARY, CUT_BUFFER0) \n`

```bash
xrdb -merge ~/.Xdefaults
```
restart Xquartz and cmd+c and cmd+v works.

# Examples

ssh port forwarding is very useful for
easy access to started containers.

From your workstation
```bash
ssh -i id_rsa -p 4848 -L 5900:127.0.0.1:5900 root@<dockerhost>
docker run -p 5900:5900 -d vncserver
```

Any container started with -p <port-ext>:<port-int> use
-L <localport>:127.0.0.1:<port-ext>

On the host you started ssh you can connect to 127.0.0.1:5900
with your vnc viewer


Or with the xorg version, a running X, and the ssh-agent
You can start a X-forward alpine danielguerra/alpine-sshx
in the docker-dind-sshd container.

From your workstation
```bash
ssh -A -p 4848 -X root@<dockerhost>
docker run -p 777 --volumes-from ssh-container --name alpine-sshdx -d danielguerra/alpine-sshdx
docker cp /root/.ssh/authorized_keys ssh-container:/root/.ssh
docker exec -ti alpine-sshdx /bin/#!/bin/sh
apk --update add firefox-esr
exit
exit
ssh -C -A -t -X -p 4848  root@<dockerhost> ssh -C -A -t -X -p 777 root@127.0.0.1 firefox
```
in the last example, each hop must have the same authorized_keys. If all went well you will see firefox.

This is a fork Git repo of the Docker [official image](https://docs.docker.com/docker-hub/official_repos/) for [docker](https://registry.hub.docker.com/_/docker/). See [the Docker Hub page](https://registry.hub.docker.com/_/docker/) for the full readme on how to use this Docker image and for information regarding contributing and issues.
