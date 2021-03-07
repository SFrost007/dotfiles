#!/bin/sh
# Thanks to https://mager.co/posts/2021-01-21-gcloud-mac-m1/ for this
# Note this also assumes the `bin` directory has been added to PATH

source "${BASH_SOURCE%/*}/inc/funcs.sh"

if ! command_exists python3; then
  echo "Requires python3 installing from brew first"; exit 1
fi

export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export CLOUDSDK_INSTALL_DIR="${HOME}/Code/SDKs/"

# Note this will attempt to execute the install script and fail with:
#    The following components are unknown [kuberun, anthoscli]
# This is safe to ignore as the install script is executed again below with
# specific components.
curl https://sdk.cloud.google.com | bash

pushd "${CLOUDSDK_INSTALL_DIR}/google-cloud-sdk" > /dev/null
./install.sh --override-components core gcloud-deps bq gcloud gsutil
popd > /dev/null

echo "Done! Reload ZSH config to update path"
