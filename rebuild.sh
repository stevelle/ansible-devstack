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

[ "$#" -eq 1 ] || die "1 argument required, $# provided"
STACKNAME=$1

IMAGE="Ubuntu 14.04 LTS (Trusty Tahr) (PVHVM)"
OUTFILE="inventory/${STACKNAME}"
IP=$(grep -v ^\; ${OUTFILE})
echo "IP = ${IP}"

if [ -z "$IP" ]; then
  echo "No IP found for ${STACKNAME}"
  exit 1
fi
echo "nova rebuild stevelle-${STACKNAME} ..."
echo ";host: stevelle-${STACKNAME}" > ${OUTFILE}

PASS=$(nova rebuild stevelle-${STACKNAME} "${IMAGE}" --poll | awk '/Pass / { print $4 }')
echo ";root: ${PASS}" >> ${OUTFILE}
echo $IP >> ${OUTFILE}

echo "verifying instance"
STATUS=$(nova show stevelle-${STACKNAME} 2>/dev/null | awk '/status/ { print $4 }')
echo ";status: $STATUS" >> ${OUTFILE}

if [ $(grep ${STACKNAME} /etc/hosts) -eq 0 ]; then
  sudo sed -i "/.*${STACKNAME}/d" /etc/hosts
  sudo sed -i "/^${IP}.*/d" /etc/hosts
fi
ssh-keygen -q -f "/home/vagrant/.ssh/known_hosts" -R ${STACKNAME}
ssh-keygen -q -f "/home/vagrant/.ssh/known_hosts" -R ${IP}
