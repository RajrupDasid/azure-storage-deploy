FROM microsoft/dotnet:2.2-runtime

RUN apt-get update \
    && apt-get install --no-install-recommends -y wget=1.* rsync=3.* libunwind8=1.* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN wget -q -O azcopyv10.tar.gz https://aka.ms/downloadazcopy-v10-linux && \
    tar -xf azcopyv10.tar.gz --strip-components=1
RUN mv ./azcopy /usr/bin/
RUN rm azcopyv10.tar.gz && rm ThirdPartyNotice.txt

COPY pipe /
RUN chmod a+x /*.sh
COPY LICENSE README.md pipe.yml /

ENTRYPOINT ["/pipe.sh"]
