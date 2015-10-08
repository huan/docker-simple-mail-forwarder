# Simple Mail Forwarder (SMF) Docker
[![](https://badge.imagelayers.io/zixia/simple-mail-forwarder:latest.svg)](https://imagelayers.io/?images=zixia/simple-mail-forwarder:latest 'Get your own badge on imagelayers.io')
![Docker Puuls](https://img.shields.io/docker/pulls/zixia/simple-mail-forwarder.svg)
[![Circle CI](https://circleci.com/gh/zixia/docker-simple-mail-forwarder/tree/master.svg?style=shield)](https://circleci.com/gh/zixia/docker-simple-mail-forwarder/)

Simplest, Easist and Smallest Email Forward Service based on Docker.
- Config by _set one variable_
- Run by _docker start_
- Image Size less than _20MB_

Github Issue - https://github.com/zixia/docker-simple-mail-forwarder/issues

## Quick Start (TL;DR)
Just set SMF_CONFIG and run. You are SET.
```bash
$ export SMF_CONFIG='from@testi.com:to@testo.com'
$ sudo docker run -p 25:25 zixia/simple-mail-forwarder
```
> Don't forget to modify the MX record of your domain. (in this example, it's _testi.com_)

## Who will need this docker
if you have a domain name, let's say: cool-domain.com. and you want your own email address from this domain, let's say: cool-user@cool-domain.com, maybe some friends else. you need a simplest way to host your domain for email address. what will you do?

some dns provider provide free email forwarding service, for their customers. some not. and some email forwarding service is not free.

then you need this docker: simple mail forwarder. deploy this docker online, set your email address and the forward address, get the docker's ip(or domain name from service), set your domain mx record to docker's ip(domain), you are set.

## Related Services

I was about to pay for xxx (xx) but the cheapest plan is $10 per 10 mails/month. Having a $5 USD machine with unlimited mail&domains/month is an amazing idea!

- https://www.cloudmailin.com/plans

## Environment Variables and Defaults

- SMF_CONFIG
    * MUST be defined. no default setting.  
- SMF_DOMAIN
    * Optional. 
    * Default: Domain from user email address.
    * Affect the following settings:
        * Hostname
        * Mailname
        * SMTP Greeting
        * Mail Header
        * etc.

### SMF_CONFIG Examples

#### 1. Basic
**Forward one email address to another.**
```bash
$ export SMF_CONFIG='from@testi.com:to@testo.com'
```
> You could get the ESMTP AUTH password for your on your docker log. It's random generated.

#### 1. Advanced
**Forward one email address to another**, with ESMTP AUTH login password.
```bash
$ export SMF_CONFIG='from@testi.com:to@testo.com:ThisIsPassword'
```
> All passwords will print on the docker log.

#### 1. Hardcore
**Forward as many email you want**, seperated by semicolons(newline supported well).
```bash
$ export SMF_CONFIG='from@testi.com:to@testo.com:ThisIsPassword;testi@from.com:testo@to.com:AnotherPassword'
```
> Tips: if you only provide the first password, and omit followings, then the passwords of all users will be the same as the first one. This is a feature.
 
## Test

1. **Build from source.**
```bash
./script/build.sh latest
```

1. **Run a self-test for SMF inside docker.**
```bash
./script/run.sh latest test
```

1. Get a shell of SMF enviroment inside docker.
```bash
./script/devshell.sh latest
```

## Author
Zhuohuan LI <zixia@zixia.net> http://linkedin.com/in/zixia
