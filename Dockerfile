FROM        harbor.lonntec.cn/lonntec-base/alpine:3.6
RUN         apk add --update ca-certificates openssl tar && \
            wget https://github.com/coreos/etcd/releases/download/v3.2.0/etcd-v3.2.0-linux-amd64.tar.gz && \
            tar xzvf etcd-v3.2.0-linux-amd64.tar.gz && \
            mv etcd-v3.2.0-linux-amd64/etcd* /bin/ && \
            apk del --purge tar openssl && \
            rm -Rf etcd-v3.2.0-linux-amd64* /var/cache/apk/*
VOLUME      /data
EXPOSE      2379 2380
ADD         run.sh /bin/run.sh
ENTRYPOINT  ["sh","/bin/run.sh"]
