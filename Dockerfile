FROM microsoft/dotnet:2.2-runtime

RUN apt-get update
RUN apt-get install -y wget rsync libunwind8
RUN wget -q -O azcopyv10.tar.gz https://aka.ms/downloadazcopy-v10-linux && \
    tar -xf azcopyv10.tar.gz --strip-components=1
RUN mv ./azcopy /usr/bin/
RUN rm azcopyv10.tar.gz && rm ThirdPartyNotice.txt

COPY pipe /
RUN chmod a+x /*.sh

ENTRYPOINT ["/pipe.sh"]
