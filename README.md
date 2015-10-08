Simple Mail Forwarder (SMF) Docker
==================================
[![](https://badge.imagelayers.io/zixia/simple-mail-forwarder:latest.svg)](https://imagelayers.io/?images=zixia/simple-mail-forwarder:latest 'Get your own badge on imagelayers.io')
![Docker Puuls](https://img.shields.io/docker/pulls/zixia/simple-mail-forwarder.svg)
[![Circle CI](https://circleci.com/gh/zixia/docker-simple-mail-forwarder/tree/master.svg?style=shield)](https://circleci.com/gh/zixia/docker-simple-mail-forwarder/)

Simplest, Easist and Smallest Email Forward Service based on Docker.

1. Config by **one variable**
1. Run by **docker start**
1. Image Size only **20MB**

Github Issue - https://github.com/zixia/docker-simple-mail-forwarder/issues

Quick Start (TL;DR)
-------------------
Just set `SMF_CONFIG` and run:
```bash
$ export SMF_CONFIG='from@testi.com:to@testo.com:test'
$ docker run -p 25:25 zixia/simple-mail-forwarder
```
> Don't forget to modify the MX record of your domain. (in this example, it's _testi.com_)

See? There is nothing easier. 

Quick Test
----------
```bash
$ telnet 127.0.0.1 25
> 220 testo.com ESMTP
ehlo test.com
> 250-testo.com
> 250-STARTTLS
> 250-AUTH PLAIN LOGIN
auth plain
> 334
dGVzdGlAdGVzdG8uY29tAHRlc3RpQHRlc3RvLmNvbQB0ZXN0
> 235 2.7.0 Authentication successful
quit
> 221 2.0.0 Bye
> Connection closed by foreign host
```
> _dGVzdGlAdGVzdG8uY29tAHRlc3RpQHRlc3RvLmNvbQB0ZXN0_  
> stands for  
> _testi@testo.com\0testi@testo.com\0test_  
> which is base64 encoded. 

You are set! :-]

Who need this docker
--------------------
if you have a domain name, let's say: cool-domain.com. and you want your own email address from this domain, let's say: cool-user@cool-domain.com, maybe some friends else. you need a simplest way to host your domain for email address. what will you do?

some dns provider provide free email forwarding service, for their customers. some not. and some email forwarding service is not free.

then you need this docker: simple mail forwarder. deploy this docker online, set your email address and the forward address, get the docker's ip(or domain name from service), set your domain mx record to docker's ip(domain), you are set.

Related Services
----------------
I was about to pay for xxx (xx) but the cheapest plan is $10 per 10 mails/month. Having a $5 USD machine with unlimited mail&domains/month is an amazing idea!

- https://www.cloudmailin.com/plans

Environment Variables and Defaults
----------------------------------
- `SMF_CONFIG`
    * MUST be defined. no default setting.  
- `SMF_DOMAIN`
    * Optional. 
    * Default: Domain from user email address.
    * Affect the following settings:
        * Hostname
        * Mailname
        * SMTP Greeting
        * Mail Header
        * etc.

### `SMF_CONFIG` Examples
Here's how to config the only parameter of SMF Docker:

#### 1. Basic
Forward one email address to another:
```bash
$ export SMF_CONFIG='from@testi.com:to@testo.com'
```
> You could get the ESMTP AUTH password for your on your docker log. It's random generated.

#### 2. Advanced
Forward one email address to another, with ESMTP AUTH login password:
```bash
$ export SMF_CONFIG='from@testi.com:to@testo.com:ThisIsPassword'
```
> All passwords will print on the docker log.

#### 3. Hardcore
Forward as many email you wantseperated by semicolons(newline supported well):
```bash
$ export SMF_CONFIG='from@testi.com:to@testo.com:ThisIsPassword;testi@from.com:testo@to.com:AnotherPassword'
```
> Tips: if you only provide the first password, and omit followings, then the passwords of all users will be the same as the first one. This is a feature.
 
Test
----
Done with [bats](https://github.com/sstephenson/bats). Useful articles:
* https://blog.engineyard.com/2014/bats-test-command-line-tools
* http://blog.spike.cx/post/60548255435/testing-bash-scripts-with-bats

How to run tests:
```bash
$ docker run zixia/simple-mail-forwarder test
>> exec bats test
1..20
ok 1 confirm hostname pretend to work.
ok 2 confirm hwclock pretend to work.
ok 3 service postfix could start/stop right.
ok 4 SMF_CONFIG exist
ok 5 SMF_DOMAIN exist
ok 6 virtual maping source is set
ok 7 virtual maping data is set
ok 8 virtual maping db is set
ok 9 system hostname FQDN resolvable
ok 10 postfix myhostname FQDN & resolvable
ok 11 check other hostname setting
ok 12 confirm postfix is running
ok 13 confirm port 25 is open
ok 14 crond is running
ok 15 ESMTP STATTLS supported
ok 16 ESMTP AUTH supported
ok 17 ESMTP STARTTLS supported
ok 18 create user testi@testo.com by password test
ok 19 ESMTP AUTH by testi@testo.com/test
ok 20 ESMTP TLS AUTH by testi@testo.com/test
```

Other Helper Scripts
--------------
1. Build from source.
```bash
./script/build.sh latest
```
1. Run a self-test for SMF inside docker.
```bash
./script/run.sh latest test
```
1. Get a shell of SMF enviroment inside docker.
```bash
./script/devshell.sh latest
```

Author
------
Zhuohuan LI <zixia@zixia.net> (http://linkedin.com/in/zixia)
