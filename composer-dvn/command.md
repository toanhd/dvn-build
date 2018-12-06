locate oderer CA_CERT
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' ../document-verification-network/crypto-config/peerOrganizations/hust.dvn.com/peers/peer0.hust.dvn.com/tls/ca.crt > ca-HUST.txt 