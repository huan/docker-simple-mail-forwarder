# docker-simple-mail-forwarder
[![](https://badge.imagelayers.io/zixia/simple-mail-forwarder:latest.svg)](https://imagelayers.io/?images=zixia/simple-mail-forwarder:latest 'Get your own badge on imagelayers.io')
![Docker Puuls](https://img.shields.io/docker/pulls/zixia/simple-mail-forwarder.svg)
[![Circle CI](https://circleci.com/gh/zixia/docker-simple-mail-forwarder/tree/master.svg?style=shield)](https://circleci.com/gh/zixia/docker-simple-mail-forwarder/)

a very simple and easy to setup email forward service based on docker cloud.

docker-simple-mail-forwarder project home - https://github.com/zixia/docker/simple-mail-forwarder

## Quick Start (TL;DR)
```bash
$ export SMF_CONFIG='from@testi.com:to@testo.com'
$ sudo docker run -p 25:25 zixia/simple-mail-forwarder
```
Just set SMF_CONFIG and run. You are SET.
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

#### Basic
```bash
$ export SMF_CONFIG='from@testi.com:to@testo.com'
```
Forward one email address to another. 
> You could get the ESMTP AUTH password for your on your docker log. It's random generated.

#### Advanced
```bash
$ export SMF_CONFIG='from@testi.com:to@testo.com:ThisIsPassword'
```
Forward one email address to another, with ESMTP AUTH login password.
> All password will print on the docker log.

#### Hardcore
```bash
$ export SMF_CONFIG='from@testi.com:to@testo.com:ThisIsPassword;testi@from.com:testo@to.com:AnotherPassword'
```
Forward as many email you want, seperated by semicolons(newline supported well).
> Tips: if you only provide the first password, and omit followings. Then the password of all users will be same as the first one. It's a feature.
 
## Test

```bash
./script/build.sh latest
```
Build from source.

```bash
./script/run.sh latest test
```
Run a self-test for SMF inside docker.

```bash
./script/devshell.sh latest
```
Get a shell of SMF enviroment inside docker.

## Author
- Zhuohuan LI <zixia@zixia.net>
