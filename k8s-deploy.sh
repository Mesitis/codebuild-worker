#!/usr/bin/env bash

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
curl -LO https://github.com/rancher/cli/releases/download/v2.0.0/rancher-linux-amd64-v2.0.0.tar.gz
tar -xvzf rancher-linux-amd64-v2.0.0.tar.gz
mv -f rancher-v2.0.0/rancher /usr/local/bin/
chmod +x /usr/local/bin/rancher && rm -rf ./rancher-v2.0.0
rm -rf rancher-v2.0.0

if [[ -z "${BRANCH}" ]]; then
  RANCHER_CREDENTIALS=${RANCHER_CREDENTIALS}
else
  RANCHER_CREDENTIALS=$(echo "RANCHER_CREDENTIALS_${BRANCH//-/_}");
  RANCHER_CREDENTIALS=${!RANCHER_CREDENTIALS}
fi

if [ -z "RANCHER_CREDENTIALS" ]
then
    echo "Rancher credentials missing. Skipping k8s deployment."
else
    mkdir -p ~/.rancher
    echo $(echo ${RANCHER_CREDENTIALS} | base64 --decode) > ~/.rancher/cli2.json
    for i in ${DEPLOYMENTS//,/ }
    do
        rancher kubectl patch deployment ${i} -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"updated-at\":\"`date +'%s'`\"}}}}}" --namespace=${NAMESPACE}
    done
fi
