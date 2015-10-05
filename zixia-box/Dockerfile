FROM debian:latest
MAINTAINER Zhuohuan LI <zixia@zixia.net>

RUN apt-get update && apt-get install --yes \
        file \
        openssh-server \
        rsyslog \
        sudo \
        telnet \
        vim

COPY    entrypoint.sh   /app/entrypoint.sh
RUN     chmod a+x       /app/entrypoint.sh

RUN     echo box.zixia.net > /etc/hostname

WORKDIR /
VOLUME ["/etc/", "/home", "/root"]

ENVIROMENT ["AUTHORIZED_KEYS"]

EXPOSE 22

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["/sbin/init"]

# Log Build Environment
RUN     echo "BUILD_DATE='`date`'"          > /etc/BUILD.env  \
    &&  echo "BUILD_HOST='`hostname`'"      >> /app/BUILD.env \
    &&  echo "GIT_BRANCH='$GIT_BRANCH'"     >> /app/BUILD.env \
    &&  echo "GIT_TAG='GIT_TAG'"            >> /app/BUILD.env \
    &&  echo "GIT_SHA1='GIT_SHA1'"          >> /app/BUILD.env \
    &&  echo "IMAGE_NAME='IMAGE_NAME'"      >> /app/BUILD.env
