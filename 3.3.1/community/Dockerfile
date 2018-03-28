FROM openjdk:8-jre-alpine

RUN apk add --no-cache --quiet \
    bash \
    curl \
    tar

ENV NEO4J_SHA256=0e5c6492cd274edf06c5f10d2b64711bd559aaff37c646e03bfa65e613994174 \
    NEO4J_TARBALL=neo4j-community-3.3.1-unix.tar.gz \
    NEO4J_EDITION=community
ARG NEO4J_URI=http://dist.neo4j.org/neo4j-community-3.3.1-unix.tar.gz

COPY ./local-package/* /tmp/

RUN curl --fail --silent --show-error --location --remote-name ${NEO4J_URI} \
    && echo "${NEO4J_SHA256}  ${NEO4J_TARBALL}" | sha256sum -csw - \
    && tar --extract --file ${NEO4J_TARBALL} --directory /var/lib \
    && mv /var/lib/neo4j-* /var/lib/neo4j \
    && rm ${NEO4J_TARBALL} \
    && mv /var/lib/neo4j/data /data \
    && ln -s /data /var/lib/neo4j/data \
    && mv /var/lib/neo4j/plugins /plugins \
    && ln -s /plugins /var/lib/neo4j/plugins

ENV PATH /var/lib/neo4j/bin:$PATH

WORKDIR /var/lib/neo4j

VOLUME /data
VOLUME /plugins

ENV MOVIEDB=http://example-data.neo4j.org/3.0-datasets/cineasts.tgz
ENV APOCF=https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/3.3.0.1/apoc-3.3.0.1-all.jar
ENV ALGOF=https://github.com/neo4j-contrib/neo4j-graph-algorithms/releases/download/3.3.0.0/graph-algorithms-algo-3.3.0.0.jar
ENV GASCF=https://products.graphaware.com/download/framework-server-community/graphaware-server-community-all-3.3.1.51.jar
ENV NEO2ES=https://products.graphaware.com/download/neo4j-to-elasticsearch/graphaware-neo4j-to-elasticsearch-3.3.1.51.7.jar

RUN curl --fail --silent --show-error --location --remote-name $MOVIEDB \
    && tar --extract --file cineasts.tgz --directory /data

RUN curl --fail --silent --show-error --location --remote-name $APOCF -o /plugins

RUN curl --fail --silent --show-error --location --remote-name $ALGOF -o /plugins

RUN curl --fail --silent --show-error --location --remote-name $GASCF -o /plugins

RUN curl --fail --silent --show-error --location --remote-name $NEO2ES -o /plugins \
    && apk del curl

COPY docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 7474 7473 7687

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["neo4j"]
