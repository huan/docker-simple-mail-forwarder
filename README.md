# docker-simple-mail-forwarder
[![](https://badge.imagelayers.io/zixia/simple-mail-forwarder:latest.svg)](https://imagelayers.io/?images=zixia/simple-mail-forwarder:latest 'Get your own badge on imagelayers.io')
![Docker Puuls](https://img.shields.io/docker/pulls/zixia/simple-mail-forwarder.svg)
[![Circle CI](https://circleci.com/gh/zixia/docker-simple-mail-forwarder/tree/master.svg?style=shield)](https://circleci.com/gh/zixia/docker-simple-mail-forwarder/)

a very simple and easy to setup email forward service based on docker cloud.

docker-simple-mail-forwarder project home - https://github.com/zixia/docker/simple-mail-forwarder

## Who will need this docker
if you have a domain name, let's say: cool-domain.com. and you want your own email address from this domain, let's say: cool-user@cool-domain.com, maybe some friends else, but not many. what will you do?

some dns provider provide free email forwarding service, for their customers. some not. and some email forwarding service is not free.

then you need this docker: simple mail forwarder. deploy this docker online, set your email address and the forward address, get the docker's ip(or domain name from service), set your domain mx record to docker's ip(domain), you are set.

## Related Services

I was about to pay for xxx (xx) but the cheapest plan is $10 per 10 mails/month. Having a $5 USD machine with unlimited mail&domains/month is an amazing idea!

 - https://www.cloudmailin.com/plans
 - 

## Environment Variables and Defaults

 - SMF_CONFIG
    * MUST be defined. no default setting.

 - SMF_DOMAIN
    * Optional. 
    * Default: Domain from user email address.
    * Name the following:
        * Hostname
        * Mailname
        * SMTP Greeting
        * Mail Header
        * etc.

## Test

Build from source:
```bash
./script/build.sh latest
```

Run a self-test for SMF inside docker:
```bash
./script/run.sh latest test
```

Get a shell of SMF enviroment inside docker:
```bash
./script/devshell.sh latest
```

## Author
 - Zhuohuan LI <zixia@zixia.net>
