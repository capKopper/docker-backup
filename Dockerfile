FROM ubuntu:14.04

## Installation
RUN apt-get update && \
    apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get install backup-manager s3cmd mysql-client python-magic -y

## Configuration
ADD config/backup-manager.conf /etc/backup-manager.conf
ADD config/s3cmd.conf /etc/s3cmd.conf
ADD init.sh /init.sh
RUN chmod u+x /init.sh

CMD ["/init.sh"]
