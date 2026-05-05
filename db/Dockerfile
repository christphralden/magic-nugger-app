FROM postgres:16-alpine

ENV PG_PARTMAN_VERSION=v5.4.3

RUN apk add --no-cache --virtual .build-deps \
    git \
    make \
    gcc \
    musl-dev \
    clang19 \
    llvm19-dev \
    icu-dev

RUN git clone --branch ${PG_PARTMAN_VERSION} https://github.com/pgpartman/pg_partman.git /tmp/pg_partman \
    && cd /tmp/pg_partman \
    && make install \
    && cd / \
    && rm -rf /tmp/pg_partman \
    && apk del .build-deps

# allow pg_partman to handle maintenance automatically
RUN echo "shared_preload_libraries = 'pg_partman_bgw'" >> /usr/local/share/postgresql/postgresql.conf.sample
