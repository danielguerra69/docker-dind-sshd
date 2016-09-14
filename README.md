# About this Repo

This repo is based on the official git repo from docker.
I added sshd,git and docker-compose to docker-dind.
Result a ssh server with behind it a complete docker server.

# Usage
First create a volume to keep authorized_keys.
```bash
tar cv --files-from /dev/null | docker import - scratch
docker create -v /root/.ssh --name ssh-container scratch /bin/true
docker cp id_rsa.pub ssh-container:/root/.ssh/authorized_keys
```

Then the sshd service
```bash
docker run -p 4848:22 --privileged --name docker-sshd --hostname docker-sshd --volumes-from ssh-container  -d danielguerra/docker-dind-sshd
```

After this ..
ssh to your new docker environment
```bash
ssh -i id_rsa -p 4848 root@<dockerhost>
```

Inside the new docker host
```bash
docker ps
docker run -ti alpine /bin/sh (Ctrl d)
wget http://docker-compose.org/docker-compose-yml
docker-compose up
```


# Example
ssh port forwarding is very useful for
easy access to started containers.
```bash
ssh -i id_rsa -p 4848 -L 5900:127.0.0.1:5900 root@<dockerhost>
docker run -p 5900:5900 -d vncserver
```
Any container started with -p <port-ext>:<port-int> use
-L <localport>:127.0.0.1:<port-ext>

On the host you started ssh you can connect to 127.0.0.1:5900
with your vnc viewer

This is a fork Git repo of the Docker [official image](https://docs.docker.com/docker-hub/official_repos/) for [docker](https://registry.hub.docker.com/_/docker/). See [the Docker Hub page](https://registry.hub.docker.com/_/docker/) for the full readme on how to use this Docker image and for information regarding contributing and issues.
