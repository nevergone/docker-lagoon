FROM ubuntu:20.04

ARG UNPRIV_USERNAME=unpriv

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG='en_US.UTF-8'
ENV LANGUAGE='en_US:en'
ENV LC_ALL='en_US.UTF-8'
ENV RUBYOPT='-KU -E utf-8:utf-8'

RUN echo $UNPRIV_USERNAME > /.unpriv_username \
    && apt-get update \
    && apt-get -qy full-upgrade \
    ## yarn and nodejs
    && apt-get install -y --force-yes --no-install-recommends ca-certificates curl gnupg locales sudo \
    && locale-gen en_US.UTF-8 \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/nodesource.gpg >/dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_14.x focal main" | sudo tee /etc/apt/sources.list.d/nodesource.list \
    && echo "deb-src [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_14.x focal main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
    && curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash - \
    && apt-get update \
    && apt-get install -qy --force-yes --no-install-recommends bash nodejs openssh-client php-cli python3 ruby wget yarn \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash \
    # https://github.com/bubenshchykov/ngrok/issues/115#issuecomment-380927124
    && npm install --unsafe-perm -g ngrok \
    && curl -sSL https://get.docker.com/ | sh \
    && curl -sSL https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && gem install pygmy \
    ## composer
    && curl -sSL https://getcomposer.org/download/latest-1.x/composer.phar -o /usr/local/bin/composer.1 \
    && curl -sSL https://getcomposer.org/download/latest-2.x/composer.phar -o /usr/local/bin/composer.2 \
    && chmod +x /usr/local/bin/composer.1 /usr/local/bin/composer.2 \
    && ln -s /usr/local/bin/composer.1 /usr/local/bin/composer \
    ## finish
    && useradd -s /bin/bash -m $UNPRIV_USERNAME -p '' \
    && usermod -aG docker $UNPRIV_USERNAME \
    && apt-get -f install \
    && apt-get autoremove --purge -y \
    && rm -rf /var/lib/apt/lists/*

COPY usr /usr

VOLUME /app
WORKDIR /app

ENTRYPOINT ["/usr/local/bin/shell"]
CMD ["/bin/bash"]
