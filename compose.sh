#!/bin/sh

docker-compose build
docker-compose -p leanote up -d
sleep 10
docker exec -ti leanote_mongodb_1 mongo --authenticationDatabase admin -u root -p foobar --eval "db.createUser({user: 'leanote', pwd: 'leanote', roles: [{ role: 'readWrite', db: 'leanote'}]});" leanote
