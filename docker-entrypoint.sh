#!/bin/bash

set -e

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- elasticsearch "$@"
fi

# Drop root privileges if we are running elasticsearch
# allow the container to be started with `--user`
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
	# Change the ownership of /usr/share/elasticsearch/data to elasticsearch
	chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/data

	set -- gosu elasticsearch "$@"
	#exec gosu elasticsearch "$BASH_SOURCE" "$@"
fi

# As argument is not related to elasticsearch,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"

#bin/plugin install https://github.com/couchbaselabs/elasticsearch-transport-couchbase/releases/download/2.2.4.0/elasticsearch-transport-couchbase-2.2.4.0.zip

#echo "couchbase.username: Administrator" >> config/elasticsearch.yml
#echo "couchbase.password: password" >> config/elasticsearch.yml

elasticsearch -Des.insecure.allow.root=true &

printf "Waiting for ElasticSearch to start\n"

while [ $(curl -s -o /dev/null -I -w "%{http_code}" http://0.0.0.0:9200/) -ne "200" ]; do
	true
done

printf "ElasticSearch started\n"

while true; do sleep 1000; done
