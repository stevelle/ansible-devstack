#!/bin/bash
# Copyright 2015, Steve Lewis <steve at-symbol stevelle period me>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

PASS=$(nova boot stevelle-${STACKNAME} --flavor $2 --image ${IMAGE} --key-name sl_mac_key --poll | awk '/Pass / { print $4 }')
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
