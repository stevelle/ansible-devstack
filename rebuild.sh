#!/bin/bash

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required, $# provided"
STACKNAME=$1

IMAGE="Ubuntu 14.04 LTS (Trusty Tahr) (PVHVM)"
OUTFILE="inventory/${STACKNAME}"
IP=$(grep -v ^\; ${OUTFILE})
echo "IP = ${IP}"

echo "nova rebuild stevelle-${STACKNAME} ..."
echo ";host: stevelle-${STACKNAME}" > ${OUTFILE}

PASS==$(nova rebuild stevelle-${STACKNAME} "${IMAGE}" --poll | awk '/Pass / { print $4 }')
echo ";root: ${PASS}" >> ${OUTFILE}
echo $IP >> ${OUTFILE}

echo "verifying instance"
STATUS=$(nova show stevelle-${STACKNAME} | awk '/status/ { print $4 }')
echo ";status: $STATUS" >> ${OUTFILE}

ssh-keygen -f "/home/vagrant/.ssh/known_hosts" -R ${STACKNAME}
ssh-keygen -f "/home/vagrant/.ssh/known_hosts" -R ${IP}
