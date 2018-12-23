function replacePemCert() {
	cp network-profile-template.json network-profile/org-profile.json

	HUST_TLS_CA_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' \
		../document-verification-network/crypto-config/peerOrganizations/hust.dvn.com/peers/peer0.hust.dvn.com/tls/ca.crt)

	MoE_TLS_CA_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' \
		../document-verification-network/crypto-config/peerOrganizations/moe.dvn.com/peers/peer0.moe.dvn.com/tls/ca.crt)

	ORDERER_TLS_CA_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' \
		../document-verification-network/crypto-config/ordererOrganizations/toanhd.com/orderers/orderer.toanhd.com/tls/ca.crt)

	sed -i "s#INSERT_ORDERER_CA_CERT#${ORDERER_TLS_CA_CERT}#g" network-profile/org-profile.json
	sed -i "s#INSERT_ORG1_CA_CERT#${HUST_TLS_CA_CERT}#g" network-profile/org-profile.json
	sed -i "s#INSERT_ORG2_CA_CERT#${MoE_TLS_CA_CERT}#g" network-profile/org-profile.json

	cp network-profile/org-profile.json network-profile/hust-profile.json
	sed -i "s#ORG_NAME#HUST#g" network-profile/hust-profile.json

	cp network-profile/org-profile.json network-profile/moe-profile.json
	sed -i "s#ORG_NAME#MoE#g" network-profile/moe-profile.json

}
set -x
rm -rf network-profile 
mkdir network-profile
set +x

# Clean the house First
set -x
composer card delete -c PeerAdmin@dvn-hust
set +x

set -x
composer card delete -c PeerAdmin@dvn-moe
set +x

set -x
composer card delete -c admin-hust@composer-dvn
set +x

set -x
composer card delete -c admin-moe@composer-dvn
set +x

HUSTMSPDIR=../document-verification-network/crypto-config/peerOrganizations/hust.dvn.com/users/Admin@hust.dvn.com/msp
MoEMSPDIR=../document-verification-network/crypto-config/peerOrganizations/moe.dvn.com/users/Admin@moe.dvn.com/msp

# Generate new connection profiles
echo
echo "Replace pem cert in connection profile"
echo
set -x
replacePemCert
res=$?
set +x

#HUST
set -x
composer card create -p network-profile/hust-profile.json -u PeerAdminHUST \
	-c $HUSTMSPDIR/signcerts/Admin@hust.dvn.com-cert.pem \
	-k $HUSTMSPDIR/keystore/*_sk \
	-r PeerAdmin -r ChannelAdmin \
	-f network-profile/PeerAdmin@dvn-hust.card
set +x
sleep 3

#Moe
set -x
composer card create -p network-profile/moe-profile.json -u PeerAdminMoE \
	-c $MoEMSPDIR/signcerts/Admin@moe.dvn.com-cert.pem \
	-k $MoEMSPDIR/keystore/*_sk \
	-r PeerAdmin -r ChannelAdmin \
	-f network-profile/PeerAdmin@dvn-moe.card
set +x
sleep 3

# import created card
set -x
composer card import -c PeerAdmin@dvn-hust -f network-profile/PeerAdmin@dvn-hust.card
set +x

set -x
composer card import -c PeerAdmin@dvn-moe -f network-profile/PeerAdmin@dvn-moe.card
set +x
