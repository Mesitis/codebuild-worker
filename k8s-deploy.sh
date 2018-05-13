#!/usr/bin/env bash

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p ~/bin
sudo mv ./kubectl ~/bin/
curl -LO https://github.com/rancher/cli/releases/download/v2.0.0/rancher-linux-amd64-v2.0.0.tar.gz
tar -xvzf rancher-linux-amd64-v2.0.0.tar.gz
chmod +x rancher-v2.0.0/rancher
mv -f rancher-v2.0.0/rancher ~/bin/
rm -rf ./rancher-v2.0.0

PATH="$(eval echo ~)/bin:$PATH"

if [[ -z "${BRANCH}" ]]; then
  RANCHER_CREDENTIALS=${RANCHER_CREDENTIALS}
  [ -z "$SKIP_EXIT" ] && exit 1;
else
  RANCHER_CREDENTIALS=$(echo "RANCHER_CREDENTIALS_${BRANCH//-/_}");
  RANCHER_CREDENTIALS=${!RANCHER_CREDENTIALS}
fi

if [ -z "RANCHER_CREDENTIALS" ]
then
    echo "Rancher credentials missing. Skipping k8s deployment."
else
    mkdir -p ~/.rancher
    echo $(echo ${RANCHER_CREDENTIALS} | base64 -d) > ~/.rancher/cli2.json
    for i in ${DEPLOYMENTS//,/ }
    do
        rancher kubectl patch deployment ${i} -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"updated-at\":\"`date +'%s'`\"}}}}}" --namespace=${NAMESPACE}
    done
fi
