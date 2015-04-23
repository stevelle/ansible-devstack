#!/bin/bash

die () {
    echo >&2 "$@"
    exit 1
}
[ "$#" -eq 2 ] || die "2 arguments required, $# provided"
STACKNAME=$1
FLAVOR=$2
echo "nova boot stevelle-${STACKNAME} ..."
echo ";host: stevelle-${STACKNAME}" > ${STACKNAME}

PASS=$(nova boot stevelle-${STACKNAME} --flavor $2 --image 8226139f-3804-4ad6-a461-97ee034b2005 --key-name sl_mac_key --poll | awk '/Pass / { print $4 }')
echo ";root: ${PASS}" >> ${STACKNAME}

echo "verifying instance"
IP=$(nova show stevelle-${STACKNAME} | awk '/public network/ { print $5, $6 }' | grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}')
echo $IP >> ${STACKNAME}
STATUS=$(nova show stevelle-${STACKNAME} | awk '/status/ { print $4 }' >> ${STACKNAME})

echo ";status: $STATUS" >> ${STACKNAME}

cat ${STACKNAME}


