## Hyperledger Network
Document Verification

## Install Prerequires
curl -O https://hyperledger.github.io/composer/v0.19/prereqs-ubuntu.sh
chmod u+x prereqs-ubuntu.sh
./prereqs-ubuntu.sh

## Download Binaries and Docker Images
curl -sSL http://bit.ly/2ysbOFE | bash -s 1.3.0

## Install Hyperledger module
npm install -g composer-cli
npm install -g composer-rest-server
npm install -g generator-hyperledger-composer
npm install -g yo

## Clone git dir
git clone https://github.com/toanhd/dvn-build.git
sudo chmod 755 -R /home/toanhd/dvn-build

## For network build by Fabric
./dvn.sh generate
./dvn.sh up
docker-compose -f docker-compose-e2e.yaml up -d 

## For Composing by Composer
./createAdminCards.sh
./bnadeploy.sh
composer-rest-server -c admin-hust@composer-dvn -n required -y toanhd -u true -d log -w true
composer-re	st-server -c admin-hust@composer-dvn -n required -u true -d y -w true

# dvn-build
