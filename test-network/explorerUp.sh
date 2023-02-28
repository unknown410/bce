#!/bin/bash

# bring up postgres instance for explorer DB
docker-compose -f explorer-db-docker.yaml up -d
echo "sleeping for 15 seconds to allow postgres server startup"
sleep 15

# create db structure
docker exec -it explorerdb.peer.com sh -c "cd dbfiles && ./createdb.sh"
res=$?

if [ $res != 0 ]
then
	echo "failed to create db structure, exiting"
	docker-compose -f explorer-db-docker.yaml down -v
	exit 1
fi

# create connection profile with proper private key file
pemfile=`ls organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore`

echo "pem file: $pemfile"
sed -e "s/PVTKEYPATH/$pemfile/g" explorer-config/connection-profile/first-network-template.json > explorer-config/connection-profile/first-network.json

# bring up explorer instance
docker-compose -f explorer-docker.yaml up -d
