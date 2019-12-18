FROM postgres:11.2 AS build
ENV VERSION 1_0
RUN buildDeps="curl build-essential ca-certificates git   pkg-config glib2.0 postgresql-server-dev-$PG_MAJOR" \
    && apt-get update \
    && apt-get install -y --no-install-recommends  ${buildDeps} \
	&& echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
	&& curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends libc++1 postgresql-server-dev-$PG_MAJOR \
    && mkdir -p /tmp/build \
    && curl -o /tmp/build/${VERSIONN}.tar.gz -SL "https://github.com/eulerto/wal2json/archive/wal2json_${VERSION}.tar.gz" \
    && cd /tmp/build/ \
    && tar -xzf /tmp/build/${VERSIONN}.tar.gz -C /tmp/build/ \
    && cd /tmp/build/wal2json-wal2json_${VERSION} \
    && make && make install \
    && cd / \
    && rm -rf /tmp/build \
    && apt-get remove -y --purge ${buildDeps} \
    && apt-get autoremove -y --purge \
    && rm -rf /var/lib/apt/lists/
RUN echo "max_replication_slots = 1" >> ${PGDATA}/postgresql.conf
RUN echo "wal_level = logical" >> ${PGDATA}/postgresql.conf