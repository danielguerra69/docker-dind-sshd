FROM docker:1.12
# X forward version ssh -X -p port -i id_rsa ip
ENV DOCKER_COMPOSE_VERSION 1.8.0
ENV COMPOSE_API_VERSION=1.18

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
RUN apk add --no-cache \
		btrfs-progs \
		e2fsprogs \
		e2fsprogs-extra \
		iptables \
		xfsprogs \
		xz \
		py-pip \
		openssh \
		git \
		util-linux \
		dbus \
		ttf-freefont \
		xauth
# build docker-compose
RUN pip install --upgrade pip \
	&& pip install -U docker-compose==${DOCKER_COMPOSE_VERSION} \
	&& rm -rf /root/.cache

# TODO aufs-tools

# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
RUN set -x \
	&& addgroup -S dockremap \
	&& adduser -S -G dockremap dockremap \
	&& echo 'dockremap:165536:65536' >> /etc/subuid \
	&& echo 'dockremap:165536:65536' >> /etc/subgid

ENV DIND_COMMIT 3b5fac462d21ca164b3778647420016315289034

RUN wget "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -O /usr/local/bin/dind \
	&& chmod +x /usr/local/bin/dind

COPY dockerd-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/docker


#make sure we get fresh keys
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

EXPOSE 2375 22
ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []
