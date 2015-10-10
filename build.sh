#!/bin/bash

die () {
    echo >&2 "$@"
    exit 1
}
[ "$#" -eq 2 ] || die "2 arguments required, $# provided"
STACKNAME=$1
FLAVOR=$2
IMAGE="Ubuntu 14.04 LTS (Trusty Tahr) (PVHVM)"
OUTFILE="inventory/${STACKNAME}"

echo "nova boot stevelle-${STACKNAME} ..."
echo ";host: stevelle-${STACKNAME}" > ${OUTFILE}

PASS=$(nova boot stevelle-${STACKNAME} --flavor "${2}" --image "${IMAGE}" --key-name sl_mac_key --poll | awk '/Pass / { print $4 }')
echo ";root: ${PASS}" >> ${OUTFILE}

echo "verifying instance"
IP=$(nova show stevelle-${STACKNAME} | awk '/public network/ { print $5, $6 }' | grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}')
echo $IP >> ${OUTFILE}
STATUS=$(nova show stevelle-${STACKNAME} | awk '/status/ { print $4 }')

echo ";status: $STATUS" >> ${OUTFILE}

if [[ ${STATUS} == "ACTIVE" ]]; then
  sudo sed -i "/.*${STACKNAME}/d" /etc/hosts
  sudo sed -i "/^${IP}.*/d" /etc/hosts
  ssh-keygen -f "/home/vagrant/.ssh/known_hosts" -R ${STACKNAME}
  ssh-keygen -f "/home/vagrant/.ssh/known_hosts" -R ${IP}
  echo "${IP}    ${STACKNAME}" | sudo tee -a /etc/hosts
else
  echo "STATUS: $STATUS"
fi
