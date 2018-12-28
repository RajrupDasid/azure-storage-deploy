FROM ubuntu:16.04

# Note: Microsoft's signing key was manually downloaded once using the following command and stored as source code
# (to avoid downloading the signing key at the same time and from the same place as the signed packages while building the image).
# curl -L https://packages.microsoft.com/keys/microsoft.asc > microsoft_signing_key.asc

COPY microsoft_signing_key.asc /root/microsoft_signing_key.asc

RUN cd /root && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install apt-transport-https lsb-release curl gnupg2 && \
    export AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" > /etc/apt/sources.list.d/azure-cli.list && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$AZ_REPO-prod/ $AZ_REPO main" > /etc/apt/sources.list.d/azure.list && \
    apt-key add microsoft_signing_key.asc && \
    apt-get update && \
    apt-get -y install azcopy

COPY pipe /usr/bin/

ENTRYPOINT ["/usr/bin/pipe.sh"]
