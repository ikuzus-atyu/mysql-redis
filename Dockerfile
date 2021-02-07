FROM mysql:8

ENV REDIS_VERSION 6.0.7

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    gcc \
    libc6-dev \
    make \
  ; \
  rm -rf /var/lib/apt/lists/*; \
    cd /usr/local/src; wget -O redis.tar.gz http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz; \
  tar -zxvf redis.tar.gz; \
  rm redis.tar.gz; \
    mv redis-${REDIS_VERSION} redis; \
    cd /usr/local/src/redis; \
  make; \
  make install; \
  rm -r /usr/local/src/redis; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  redis-cli --version; \
  redis-server --version

ADD https://github.com/jwilder/forego/releases/download/v0.16.1/forego /usr/local/bin/forego
RUN chmod +x /usr/local/bin/forego

EXPOSE 3306 6379

RUN echo "mysql: /entrypoint.sh mysqld\n\
redis: redis-server --protected-mode no" > /Procfile

RUN \
  echo "[mysqld]" > /etc/mysql/conf.d/default_authentication.cnf && \
  echo "default_authentication_plugin=mysql_native_password" >> /etc/mysql/conf.d/default_authentication.cnf

ENTRYPOINT [ "forego", "start", "-r" ]
