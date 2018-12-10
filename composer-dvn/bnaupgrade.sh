APPVERSION=0.0.154

composer archive create -t dir -n ../composer/vnclinet

set -x
composer network install -c PeerAdmin@moh.vnclinet.com --archiveFile vnclinet@$APPVERSION.bna
set +x
sleep 5

set -x
composer network install -c PeerAdmin@hos.vnclinet.com --archiveFile vnclinet@$APPVERSION.bna
set +x
sleep 5

set -x
composer network install -c PeerAdmin@clinic.vnclinet.com --archiveFile vnclinet@$APPVERSION.bna
set +x
sleep 5

set -x
composer network install -c PeerAdmin@vtt.vnclinet.com --archiveFile vnclinet@$APPVERSION.bna
set +x
sleep 5

set -x
composer network install -c PeerAdmin@vsp.vnclinet.com --archiveFile vnclinet@$APPVERSION.bna
set +x
sleep 5

set -x
composer network upgrade  -c PeerAdmin@moh.vnclinet.com \
                        -n vnclinet \
                        -V $APPVERSION \
                        -o endorsementPolicyFile=endorspol.json

set +x


set -x
composer network ping -c admin-moh@vnclinet
set +x
