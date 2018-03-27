FROM openjdk:8-jre-alpine

RUN addgroup -S neo4j && adduser -S -H -h /var/lib/neo4j -G neo4j neo4j

ENV NEO4J_SHA256=cc2fda6ededfc4678d1fc9be9dc1c5c2902fe2bc184125b59ae6f9183a98571c \
    NEO4J_TARBALL=neo4j-community-3.3.4-unix.tar.gz \
    NEO4J_EDITION=community
ARG NEO4J_URI=http://dist.neo4j.org/neo4j-community-3.3.4-unix.tar.gz

COPY ./local-package/* /tmp/

RUN apk add --no-cache --quiet \
    bash \
    curl \
    tini \
    su-exec \
    && curl --fail --silent --show-error --location --remote-name ${NEO4J_URI} \
    && echo "${NEO4J_SHA256}  ${NEO4J_TARBALL}" | sha256sum -csw - \
    && tar --extract --file ${NEO4J_TARBALL} --directory /var/lib \
    && mv /var/lib/neo4j-* /var/lib/neo4j \
    && rm ${NEO4J_TARBALL} \
    && mv /var/lib/neo4j/data /data \
    && chown -R neo4j:neo4j /data \
    && chmod -R 777 /data \
    && chown -R neo4j:neo4j /var/lib/neo4j \
    && chmod -R 777 /var/lib/neo4j \
    && ln -s /data /var/lib/neo4j/data \
    && apk del curl

ENV PATH /var/lib/neo4j/bin:$PATH

WORKDIR /var/lib/neo4j

VOLUME /data


DATA_FILE="panama-papers-mac-2016-06-27.tar.gz"
if [ ! -f "./$DATA_FILE" ]; then
  echo "Downloading data"
  wget "https://cloudfront-files-1.publicintegrity.org/offshoreleaks/neo4j/$DATA_FILE"
else
  echo "Not downloading data as file already exists"
fi

if [ ! -d "./panama-papers" ]; then
  tar -zxvf "$DATA_FILE"
fi

if [ ! -d "/data/databases/panama.graphdb" ]; then
  echo "Copying data over to databases directory"
  cp -R ./panama-papers/ICIJ\ Panama\ Papers/panama_data_for_neo4j/databases /data/
else
  echo "Skipping copying data over to databases directory as panama.graphdb already exists"
fi

echo "Copying config and plugins"
cp -R ./panama-papers/ICIJ\ Panama\ Papers/panama_data_for_neo4j/conf/* /var/lib/neo4j/conf/
mkdir /var/plugins
cp -R ./panama-papers/ICIJ\ Panama\ Papers/panama_data_for_neo4j/plugins/* /var/plugins/





COPY docker-entrypoint.sh /docker-entrypoint.sh


EXPOSE 7474 7473 7687

ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
CMD ["neo4j"]
