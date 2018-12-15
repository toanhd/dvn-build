APPVERSION=0.0.3

composer archive create -t dir -n . #create bna file

set -x
composer network install --card PeerAdmin@dvn-hust --archiveFile composer-dvn@$APPVERSION.bna
set +x
sleep 5

set -x
composer network install --card PeerAdmin@dvn-moe --archiveFile composer-dvn@$APPVERSION.bna
set +x
sleep 5

set -x
composer network upgrade  -c PeerAdmin@dvn-hust \
                        -n composer-dvn \
                        -V $APPVERSION \
                        -o endorsementPolicyFile=endorspol.json

set +x

set -x
composer network ping -c admin-hust@composer-dvn
set +x
echo "timeout for 5 sec"
sleep 5