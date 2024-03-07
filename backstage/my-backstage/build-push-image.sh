#!/usr/bin/bash
echo "Enter the new image tag:"
read IMAGE_TAG

yarn install --frozen-lockfile

# tsc outputs type definitions to dist-types/ in the repo root, which are then consumed by the build
yarn tsc

# Build the backend, which bundles it all up into the packages/backend/dist folder.
# The configuration files here should match the one you use inside the Dockerfile below.
yarn build:backend --config ../../app-config.production.yaml

docker image build . -f packages/backend/Dockerfile --tag tferrari92/backstage:$IMAGE_TAG
docker push tferrari92/backstage:$IMAGE_TAG

# echo "#############################################################################"
# echo "#############################################################################"
# echo "#############################################################################"
# echo " "
# echo "REMEMBER TO UPDATE THE IMAGE TAG IN THE values-custom.yaml FILE OF THE BACKSTAGE HELM CHART!!!"
# echo " "
# echo "#############################################################################"
# echo "#############################################################################"
# echo "#############################################################################"