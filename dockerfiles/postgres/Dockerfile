FROM postgres:18-bookworm

COPY ./initdb /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/*.sh
