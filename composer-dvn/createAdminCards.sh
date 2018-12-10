function replacePemCert() {
	cp network-profile/network-profile-template.json network-profile/org-profile.json

	HUST_TLS_CA_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' \
		../document-verification-network/crypto-config/peerOrganizations/hust.dvn.com/peers/peer0.hust.dvn.com/tls/ca.crt)

	MoE_TLS_CA_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' \
		../document-verification-network/crypto-config/peerOrganizations/moe.dvn.com/peers/peer0.moe.dvn.com/tls/ca.crt)

	ORDERER_TLS_CA_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' \
		../document-verification-network/crypto-config/ordererOrganizations/toanhd.com/orderers/orderer.toanhd.com/tls/ca.crt)

	sed -i "s#ORDERER_CERT_PEM#${ORDERER_TLS_CA_CERT}#g" network-profile/org-profile.json
	sed -i "s#MOH_CERT_PEM#${HUST_TLS_CA_CERT}#g" network-profile/org-profile.json
	sed -i "s#HOS_CERT_PEM#${MoE_TLS_CA_CERT}#g" network-profile/org-profile.json

	cp network-profile/org-profile.json network-profile/hust-profile.json
	sed -i "s#ORG_NAME#MOHMSP#g" network-profile/hust-profile.json

	cp network-profile/org-profile.json network-profile/moe-profile.json
	sed -i "s#ORG_NAME#HOSMSP#g" network-profile/moe-profile.json

}

# Clean the house First
#set -x
#composer card delete -c PeerAdminMOH@moh.vnclinet.com
#set +x

#set -x
#composer card delete -c PeerAdminHOS1@hos1.vnclinet.com
#set +x

#set -x
#composer card delete -c admin-moh@health-network
#set +x

#set -x
#composer card delete -c admin-hos1@health-network
#set +x

#TuanPV-luu y bo dau / o cuoi msp neu khong o lenh duoi khi ghep voi keystore se thanh msp//keystore
#Luc nay he thong se bao loi no such directory
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
	-f PeerAdmin@dvn-hust.card
set +x
sleep 3

#HUST
set -x
composer card create -p network-profile/moe-profile.json -u PeerAdminMoE \
	-c $MoEMSPDIR/signcerts/Admin@moe.dvn.com-cert.pem \
	-k $MoEMSPDIR/keystore/*_sk \
	-r PeerAdmin -r ChannelAdmin \
	-f PeerAdmin@dvn-moe.card
set +x
sleep 3

set -x
composer card import -c PeerAdmin@dvn-hust -f PeerAdmin@dvn-hust.card
set +x

set -x
composer card import -c PeerAdmin@dvn-moe -f PeerAdmin@dvn-moe.card
set +x
