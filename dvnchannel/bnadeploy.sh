#!/usr/bin/env bash
function createBNCard() {
        echo
        echo
        echo "Processing for admin of $1"
        set -x
        composer identity request -c PeerAdmin@dvn-$1  -u admin$1 -s admin$1pw -d admin-$1
        set +x

        # Add participant
        set -x
        composer participant add -c admin-hust@dvnchannel \
                -d '{"$class":"org.hyperledger.composer.system.NetworkAdmin","participantId":"admin'$1'"}'
        set +x

        # Bind identity
        set -x
        composer identity bind -c admin-hust@dvnchannel \
                        -a org.hyperledger.composer.system.NetworkAdmin#admin$1 \
                        -e admin-$1/admin$1-pub.pem
        set +x

        # Create card
        set -x
        composer card create -p network-profile/$1-profile.json  \
                        -u admin-$1 \
                        -n dvnchannel \
                        -c admin-$1/admin$1-pub.pem \
                        -k admin-$1/admin$1-priv.pem
        set +x

        # Import cardstarting time for cert might have been met until few minutes on client elapsed)
        set -x
        composer card import -f admin-$1@dvnchannel.card

        set +x

        # Test ping
        set -x
        composer network ping -c admin-$1@dvnchannel
        set +x
}

APPVERSION=0.0.1

composer archive create -t dir -n . #create bna file

set -x
composer network install --card PeerAdmin@dvn-hust --archiveFile dvnchannel@$APPVERSION.bna
set +x
sleep 5

set -x
composer network install --card PeerAdmin@dvn-moe --archiveFile dvnchannel@$APPVERSION.bna
set +x
sleep 5

# Request identity for main admin
set -x
composer identity request -c PeerAdmin@dvn-hust  -u adminhust -s adminhustpw -d admin-hust
set +x

echo
echo
echo "Waiting for things to start up. 10 secs..."
echo
sleep 10

set -x
composer network start  -c PeerAdmin@dvn-hust \
                        -n dvnchannel \
                        -V $APPVERSION \
                        -o endorsementPolicyFile=endorspol.json \
                        -A admin-hust \
                        -C admin-hust/adminhust-pub.pem \
                        -K admin-hust/adminhust-priv.pem
set +x

echo
echo
echo "Waiting for things to start up. 120 secs..."
echo
sleep 10

set -x
composer card import -f admin-hust@dvnchannel.card
set +x
echo "timeout for 5 sec"
sleep 5

set -x
composer network ping -c admin-hust@dvnchannel
set +x
echo "timeout for 5 sec"
sleep 5

# create BNCard for another org
createBNCard moe
