Simple Mail Forwarder (SMF) Docker
==================================
[![](https://badge.imagelayers.io/zixia/simple-mail-forwarder:latest.svg)](https://imagelayers.io/?images=zixia/simple-mail-forwarder:latest 'Get your own badge on imagelayers.io')
![Docker Puuls](https://img.shields.io/docker/pulls/zixia/simple-mail-forwarder.svg)
[![Circle CI](https://circleci.com/gh/zixia/docker-simple-mail-forwarder/tree/master.svg?style=shield)](https://circleci.com/gh/zixia/docker-simple-mail-forwarder/)
[![Deploy to Tutum](https://s.tutum.co/deploy-to-tutum.svg)](https://dashboard.tutum.co/stack/deploy/?repo=https://github.com/zixia/docker-simple-mail-forwarder)


Simplest, Easist and Smallest Email Forward Service based on Docker.

1. Config by [**one line**](#environment-variable-and-default)
1. Run as [**docker start**](#quick-start-tldr)
1. Image Size [**10MB**](https://hub.docker.com/r/zixia/simple-mail-forwarder/tags/)

View on Github - https://github.com/zixia/docker-simple-mail-forwarder

What is SMF? (Simple Mail Forwarder)
------------------------------------
If you have a domain name, only want to have a(or a few) email address from this domain, but forward all the emails to gmail(etc). SMF is exactly what you need. (with [Docker](http://docker.com))

This docker was built for maximum **simple** & **easy** to use because of this reason. I had many domains and need email address of them(for fun/work), and I hate config mail server. Some dns providers provide free email forwarding service for their own domain. some do not. And almose all email forwarding service is not free. So I decided to make it myself(thanks docker).

### Related Services
- [DuoCircle Email Forwarding](http://www.duocircle.com/services/email-forwarding) From $59.95/year
- [Cloud Mail In](https://www.cloudmailin.com/plans) From $9/month. And it is not for human. 

I was about to pay $10/year maybe, but the cheapest plan is $9 per month. Having a $10 USD machine with unlimited mail&domains/month is an amazing idea! And of couse you also could put other dockers in this machine. :-D

Quick Start (TL;DR)
-------------------
Just set `SMF_CONFIG` and run:
```bash
$ export SMF_CONFIG='testi@testo.com:test@test.com:test'
$ docker run -p 25:25 zixia/simple-mail-forwarder
```
> Don't forget to modify the DNS MX record of your domain. (in this example, it's _testo.com_)

This will forward all email received by testi@testo.com, to test@test.com.

See? There is nothing easier. 

Quick Test
----------
Done with [BATS(Bash Automated Testing System)](https://github.com/sstephenson/bats), a bash implementation of [TAP(Test Anything Protol)]( http://testanything.org).

How to run:
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

You are set! :-]

Environment Variable and Default
----------------------------------
`SMF_CONFIG`: MUST be defined. no default setting. (set me! I'm the only parameter~)

### `SMF_CONFIG` Examples
Here's how to config the only environment parameter of SMF Docker:

#### 1. Basic
Forward all email received by testi@testo.com, to test@test.com:
```bash
$ export SMF_CONFIG='testi@testo.com:test@test.com'
```
> You could get the ESMTP AUTH password for your on your docker log. It's random generated if you do not provide one.

#### 2. Advanced
Add ESMTP AUTH password:
```bash
$ export SMF_CONFIG='from@testi.com:to@testo.com:ThisIsPassword'
```
> Password will print on the docker log.

#### 3. Hardcore
Add as many email as you want, with or without password. Seperated by semicolons or newline:
```bash
$ export SMF_CONFIG='testi@testo.com:test@test.com:ThisIsPassword;testo@testi.com:test@test.com:AnotherPassword'
```
> Tips: if you only provide the first password, and omit followings, then the passwords of all users will be the same as the password last seen. This is a feature.
 
Helper Scripts
--------------------
1. Build from source.
```bash
$ ./script/build.sh latest
```

2. Run a self-test for SMF docker.
```bash
$ ./script/run.sh latest test
```

3. Get a shell inside SMF docker.
```bash
$ ./script/devshell.sh latest
```

### Test by Hand
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

P.S. The magic string `dGVzdGlAdGVzdG8uY29tAHRlc3RpQHRlc3RvLmNvbQB0ZXN0` stands for `testi@testo.com\0test@testo.com\0test` in base64 encode, required by AUTH PLAIN.

> Useful article about SMTP Authentication: http://www.fehcom.de/qmail/smtpauth.html

Bug
---
Github Issue - https://github.com/zixia/docker-simple-mail-forwarder/issues

Changelog
---------
### v0.3.0
* add deploy to Tutum Button
* use CircleCI for continuous integration
* write better tests
* tune OpenRC inside alpine linux
* full description README
* [docker image size: 7MB](https://hub.docker.com/r/zixia/simple-mail-forwarder/tags/)

### ~~v0.2.0~~ <- Don'tt use me, I'm BUGGY
* supported specify user password
* supported ESMTP TLS
* [docker image size: 7MB](https://hub.docker.com/r/zixia/simple-mail-forwarder/tags/)

### v0.1.0
* dockerized
* basic forward function
* self-testing
* [docker image size: 6MB](https://hub.docker.com/r/zixia/simple-mail-forwarder/tags/)

Cloud Requirement
-----------------
* A Cloud Service that could host docker is required.
  * DigitalOcean.com
* A Docker management platform is recommanded.
  * Tutum.co [![Deploy to Tutum](https://s.tutum.co/deploy-to-tutum.svg)](https://dashboard.tutum.co/stack/deploy/?repo=https://github.com/zixia/docker-simple-mail-forwarder)
* Docker is required.
  * Docker.com

Author
-----------------
Zhuohuan LI <zixia@zixia.net> (http://linkedin.com/in/zixia)

Copyright & License
-------------------
* Code & Documentation 2015© zixia
* Code released under the Apache 2.0 license
* Docs released under Creative Commons
