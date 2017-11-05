#!/bin/bash

confFileTmpl=/leanote/conf/app.conf.tmpl
confFile=/leanote/conf/app.conf
envFile=/leanote/conf/env.sh

echo "" > ${envFile}

IFS=$'\n'
for line in $(cat ${confFileTmpl} | grep -v -P '\s*#' | grep '=' ); do
    key=$(echo ${line} | cut -d '=' -f1 | tr -d ' \n')
    value=$(echo ${line} | cut -d '=' -f2 | tr -d '\n')
    envKey="LN"
    oifs=${IFS}
    IFS='.'
    for keyPart in ${key}; do
        envKey=${envKey}"_${keyPart}"
    done
    IFS=${oifs}

    envKey=$(echo ${envKey} | tr '[:lower:]' '[:upper:]')
    echo "export ${envKey}=\${${envKey}:-'${value}'}" >> ${envFile}
done

source /leanote/conf/env.sh
echo "" > ${confFile}

for line in $(cat ${confFileTmpl} | grep -v -P '\s*#' | grep =); do
    key=$(echo ${line} | cut -d '=' -f1 | tr -d ' \n')
    envKey="LN"
    oifs=${IFS}
    IFS='.'
    for keyPart in ${key}; do
        envKey=${envKey}"_${keyPart}"
    done
    IFS=${oifs}
    envKey=$(echo ${envKey} | tr '[:lower:]' '[:upper:]')
    echo "${key}=${!envKey}" >> ${confFile}
done
echo 'adminUsername=admin' >> ${confFile}

# set -e after this command because grep must be allowed to fail
mongo --eval 'db.getCollectionNames()' -u ${LN_DB_USERNAME} -p ${LN_DB_PASSWORD} \
${LN_DB_HOST}:${LN_DB_PORT}/${LN_DB_DBNAME} | grep -q "users"
rc="$?"

set -e
if [ "${rc}" != "0" ]; then
    mongorestore -h ${LN_DB_HOST} -d ${LN_DB_DBNAME} -u ${LN_DB_USERNAME} -p ${LN_DB_PASSWORD} --dir /leanote/mongodb_backup/leanote_install_data/
    # remove the demo user to disable the demo feature
    mongo -h  ${LN_DB_HOST} -d ${LN_DB_DBNAME} -u ${LN_DB_USERNAME} -p ${LN_DB_PASSWORD} --eval 'db.users.remove({"Username":"demo"})' leanote
fi

gosu leanote /leanote/bin/leanote-linux-amd64 -importPath github.com/leanote/leanote
