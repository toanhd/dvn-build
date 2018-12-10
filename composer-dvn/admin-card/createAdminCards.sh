function replacePemCert () {
  cp byfn-network-template.json byfn-network-org0.json

  MOH_TLS_CA_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' \
  ../crypto-config/peerOrganizations/moh.vnclinet.com/peers/peer0.moh.vnclinet.com/tls/ca.crt)

  HOS_TLS_CA_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' \
  ../crypto-config/peerOrganizations/hos.vnclinet.com/peers/peer0.hos.vnclinet.com/tls/ca.crt)

  # HD1_TLS_CA_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' \
  # ../crypto-config/peerOrganizations/hd1.vnclinet.com/peers/peer0.hd1.vnclinet.com/tls/ca.crt)

  # VSP_TLS_CA_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' \
  # ../crypto-config/peerOrganizations/vsp.vnclinet.com/peers/peer0.vsp.vnclinet.com/tls/ca.crt)

  ORDERER_TLS_CA_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' \
  ../crypto-config/ordererOrganizations/vnclinet.com/orderers/orderer0.vnclinet.com/tls/ca.crt)

  sed -i "s#ORDERER_CERT_PEM#${ORDERER_TLS_CA_CERT}#g" byfn-network-org0.json
  sed -i "s#MOH_CERT_PEM#${MOH_TLS_CA_CERT}#g" byfn-network-org0.json
  sed -i "s#HOS_CERT_PEM#${HOS_TLS_CA_CERT}#g" byfn-network-org0.json
  # sed -i "s#HD1_CERT_PEM#${HD1_TLS_CA_CERT}#g" byfn-network-org0.json
  # sed -i "s#VSP_CERT_PEM#${VSP_TLS_CA_CERT}#g" byfn-network-org0.json

  cp byfn-network-org0.json byfn-network-moh.json
  sed -i "s#ORG_NAME#MOHMSP#g" byfn-network-moh.json

  cp byfn-network-org0.json byfn-network-hos.json
  sed -i "s#ORG_NAME#HOSMSP#g" byfn-network-hos.json

  # cp byfn-network-org0.json byfn-network-hd1.json
  # sed -i "s#ORG_NAME#HD1MSP#g" byfn-network-hd1.json

  # cp byfn-network-org0.json byfn-network-vsp.json
  # sed -i "s#ORG_NAME#VSPMSP#g" byfn-network-vsp.json
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
ORG1MSPDIR=../crypto-config/peerOrganizations/moh.vnclinet.com/users/Admin@moh.vnclinet.com/msp
 ORG2MSPDIR=../crypto-config/peerOrganizations/hos.vnclinet.com/users/Admin@hos.vnclinet.com/msp
# ORG4MSPDIR=../crypto-config/peerOrganizations/hd1.vnclinet.com/users/Admin@hd1.vnclinet.com/msp
# ORG6MSPDIR=../crypto-config/peerOrganizations/vsp.vnclinet.com/users/Admin@vsp.vnclinet.com/msp

# Generate new connection profiles
echo
echo "Replace pem cert in connection profile"
echo
set -x
replacePemCert
res=$?
set +x

#Org 1
set -x
composer card create -p byfn-network-moh.json -u PeerAdminMOH \
  -c $ORG1MSPDIR/signcerts/Admin@moh.vnclinet.com-cert.pem \
  -k $ORG1MSPDIR/keystore/*_sk \
  -r PeerAdmin -r ChannelAdmin \
  -f PeerAdminMOH@network-moh.card
set +x
sleep 3

#Org 2
set -x
composer card create -p byfn-network-hos.json -u PeerAdminHOS \
  -c $ORG2MSPDIR/signcerts/Admin@hos.vnclinet.com-cert.pem \
  -k $ORG2MSPDIR/keystore/*_sk \
  -r PeerAdmin -r ChannelAdmin \
  -f PeerAdminHOS@network-hos.card
set +x
sleep 3

# #Org 4
# set -x
# composer card create -p byfn-network-hd1.json -u PeerAdminHD1 \
#   -c $ORG4MSPDIR/signcerts/Admin@hd1.vnclinet.com-cert.pem \
#   -k $ORG4MSPDIR/keystore/*_sk \
#   -r PeerAdmin -r ChannelAdmin \
#   -f PeerAdminHD1@network-hd1.card
# set +x
# sleep 3

# #Org 6
# set -x
# composer card create -p byfn-network-vsp.json -u PeerAdminVSP \
#   -c $ORG6MSPDIR/signcerts/Admin@vsp.vnclinet.com-cert.pem \
#   -k $ORG6MSPDIR/keystore/*_sk \
#   -r PeerAdmin -r ChannelAdmin \
#   -f PeerAdminVSP@network-vsp.card
# set +x
# sleep 3

set -x
composer card import -c PeerAdmin@moh.vnclinet.com -f PeerAdminMOH@network-moh.card
set +x

set -x
composer card import -c PeerAdmin@hos.vnclinet.com -f PeerAdminHOS@network-hos.card
set +x

# set -x
# composer card import -c PeerAdmin@hd1.vnclinet.com -f PeerAdminHD1@network-hd1.card
# set +x

# set -x
# composer card import -c PeerAdmin@vsp.vnclinet.com -f PeerAdminVSP@network-vsp.card
# set +x
