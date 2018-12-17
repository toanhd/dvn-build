## Hyperledger Network
Document Verification

## Download Binaries and Docker Images

The [`scripts/bootstrap.sh`](https://github.com/hyperledger/fabric-samples/blob/release-1.3/scripts/bootstrap.sh)
script will preload all of the requisite docker
images for Hyperledger Fabric and tag them with the 'latest' tag. Optionally,
specify a version for fabric, fabric-ca and thirdparty images. Default versions
are 1.3.0, 1.3.0 and 0.4.13 respectively.

```bash
./scripts/bootstrap.sh [version] [ca version] [thirdparty_version]
```

# dvn-build
