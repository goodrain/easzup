FROM easzlab/kubeasz:2.1.0

RUN sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/" /etc/apk/repositories && \
    apk update && \
    apk add pwgen util-linux curl

COPY ./ansible-file/ /etc/ansible/

COPY ./easzup /etc/ansible/tools/easzup

COPY ./easzctl /usr/bin/easzctl
COPY ./easzctl /etc/ansible/tools/easzctl