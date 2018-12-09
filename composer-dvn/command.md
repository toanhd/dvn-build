// locate HUST CA_CERT

awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' ../document-verification-network/crypto-config/peerOrganizations/hust.dvn.com/peers/peer0.hust.dvn.com/tls/ca.crt > network-profile/ca-HUST.txt 

------------------
// locate MoE CA_CERT

awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' ../document-verification-network/crypto-config/peerOrganizations/moe.dvn.com/peers/peer0.moe.dvn.com/tls/ca.crt > network-profile/ca-MoE.txt 

------------------
// locate Orderer CA_CERT

awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' ../document-verification-network/crypto-config/ordererOrganizations/toanhd.com/orderers/orderer.toanhd.com/tls/ca.crt > network-profile/ca-oderer.txt 

------------------
// locate certificate and private key for administrator for HUST
export HUST=../document-verification-network/crypto-config/peerOrganizations/hust.dvn.com/users/Admin@hust.dvn.com/msp
mkdir network-profile/admin-hust
cp -p $HUST/signcerts/A*.pem network-profile/admin-hust
cp -p $HUST/keystore/*_sk network-profile/admin-hust

------------------
// locate certificate and private key for administrator for MoE
export MoE=../document-verification-network/crypto-config/peerOrganizations/moe.dvn.com/users/Admin@moe.dvn.com/msp
mkdir network-profile/admin-moe
cp -p $MoE/signcerts/A*.pem network-profile/admin-moe
cp -p $MoE/keystore/*_sk network-profile/admin-moe

------------------
// Replace CA_CERT for HUST & Moe
find and replace these content
INSERT_ORDERER_CA_CERT
INSERT_ORG1_CA_CERT
INSERT_ORG2_CA_CERT

------------------
//Create business network card for HUST

composer card create -p network-profile/hust-profile.json -u PeerAdmin -c network-profile/admin-hust/Admin@hust.dvn.com-cert.pem -k network-profile/admin-hust/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@dvn-hust.card

------------------
//Create business network card for MoE

composer card create -p network-profile/moe-profile.json -u PeerAdmin -c network-profile/admin-moe/Admin@moe.dvn.com-cert.pem -k network-profile/admin-moe/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@dvn-moe.card

------------------
//Import card for HUST & MoE

composer card import -f PeerAdmin@dvn-hust.card --card PeerAdmin@dvn-hust
composer card import -f PeerAdmin@dvn-moe.card --card PeerAdmin@dvn-moe

------------------
// Install created card for network using .bna file

composer network install --card PeerAdmin@dvn-hust --archiveFile document-verification-network.bna
composer network install --card PeerAdmin@dvn-moe --archiveFile document-verification-network.bna