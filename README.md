
==================================
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/dimitrovs/docker-simple-mail-forwarder-armhf?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![](https://badge.imagelayers.io/stefand/simple-mail-forwarder-armhf:latest.svg)](https://imagelayers.io/?images=stefand/simple-mail-forwarder-armhf:latest 'Get your own badge on imagelayers.io')
[![Docker Puuls](https://img.shields.io/docker/pulls/stefand/simple-mail-forwarder-armhf.svg)](https://hub.docker.com/r/stefand/simple-mail-forwarder-armhf/)
![Docker Stars](https://img.shields.io/docker/stars/stefand/simple-mail-forwarder-armhf.svg?maxAge=2592000)

[![dockeri.co](http://dockeri.co/image/stefand/simple-mail-forwarder-armhf)](https://hub.docker.com/r/stefand/simple-mail-forwarder-armhf/)

Simplest and Smallest Email Forward Service based on Docker for your Raspberry Pi or Scaleway instance.

1. Config by [**one line**](#environment-variable-and-default)
1. Run as [**docker start**](#quick-start-tldr)
1. Image Size [**10MB**](https://hub.docker.com/r/zixia/simple-mail-forwarder/tags/)

View on Github - https://github.com/dimitrovs/docker-simple-mail-forwarder-armhf

ARM fork of: [zixia/docker-simple-mail-forwarder](https://github.com/zixia/docker-simple-mail-forwarder) .

Voice from Users
------------------------------------
> @Brian Christner : After testing a ton of different mail projects I finally discovered Simple Mail Forwarder (SMF) by Zixia. This image is based on Alpine which is already a positive. It is super tiny and as the name suggests, easy to use. [link](https://www.brianchristner.io/setting-up-a-mail-forwarder-in-docker/)

> @kachkaev : really happy to discover it! [link](https://github.com/zixia/docker-simple-mail-forwarder/issues/5#issue-165988701)

> @kiani: have a working mail server, seriously, it was that easy. [link](https://kiani.io/blog/custom-domain-mail-forward)

What is SMF? (Simple Mail Forwarder)
------------------------------------
If you have a domain name and only want to have one (or a few) email address on this domain, while forwarding all emails to another email account, SMF is exactly what you need. (with [Docker](http://docker.com) for ARM )

This docker image was built for ultimate **simplicity** . I own many domains and need email addresses for them (for fun/work), and I hate to configure email serverers. Some DNS providers provide free email forwarding service with domain purchase, some do not. And almose all email forwarding services are NOT free. I have a number of Raspberry Pi devices, some of them colocated in datacenters, so I decided to port Zhuohuan LI's SMF to ARM. All credit goes to Zhuohuan LI: https://github.com/zixia/docker-simple-mail-forwarder .

Quick Start (TL;DR)
-------------------
Just set `SMF_CONFIG` and run:
```bash
$ export SMF_CONFIG='testi@testo.com:test@test.com'
$ docker run  -e SMF_CONFIG=$SMF_CONFIG -p 25:25 stefand/simple-mail-forwarder-armhf
```
> Don't forget to modify the DNS MX record of your domain. (in this example, it's _testo.com_)

This will forward all emails received by testi@testo.com to test@test.com.

See? There is nothing easier. 

Quick Test
----------
Tested by [BATS(Bash Automated Testing System)](https://github.com/sstephenson/bats), a bash implementation of [TAP(Test Anything Protol)]( http://testanything.org).

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

You are all set! :-]

Environment Variable and Default Values
----------------------------------
`SMF_CONFIG`: MUST be defined. no default setting. (set me! I'm the only parameter~)

### `SMF_CONFIG` Examples
Here's how to config the only environment parameter of SMF Docker:

#### 1. Basic
Forward all emails received by testi@testo.com to test@test.com:
```bash
$ export SMF_CONFIG='testi@testo.com:test@test.com'
```
> You could get the ESMTP AUTH password for you on your docker log. It's randomly generated if you do not provide one.

#### 2. Advanced
Add ESMTP AUTH password:
```bash
$ export SMF_CONFIG='from@testi.com:to@testo.com:ThisIsPassword'
```
> Password will be printed on the docker log.

#### 3. Hardcore
Add as many email accounts as you want, with or without password. Seperated by semicolon or a new line:
```bash
$ export SMF_CONFIG='testi@testo.com:test@test.com:ThisIsPassword;testo@testi.com:test@test.com:AnotherPassword'
```
> Tips: if you only provide the first password and leave the rest blank, then the passwords for all the rest accounts will be the same as the last password value you set. This is by design.

You can also forward all emails received by testi@testo.com to multiple destination addresses:

```bash
$ export SMF_CONFIG='testi@testo.com:test1@test.com|test2@test.com|test3@test.com'
```

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

### Manual Test
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

P.S. The magic string `dGVzdGlAdGVzdG8uY29tAHRlc3RpQHRlc3RvLmNvbQB0ZXN0` stands for `testi@testo.com\0test@testo.com\0test` in base64 encoding, required by AUTH PLAIN.

> Useful article about SMTP Authentication: http://www.fehcom.de/qmail/smtpauth.html

Bug
---
Github Issue - https://github.com/zixia/docker-simple-mail-forwarder/issues
For ARM specific: https://github.com/dimitrovs/docker-simple-mail-forwarder-armhf/issues

Hardware Requirement
-----------------
* ARM-based board is required (ARMv6+)
  * Tested on Raspberry Pi Model B
* Docker for ARM is required.
  * Docker.com
  * 
NOTE: THIS IMAGE IS NOT FOR YOUR PC/MAC/VPS/CloudServer! This image is for ARM boards. If you don't know what this means you are most likely looking for: https://github.com/zixia/docker-simple-mail-forwarder

Author
-----------------
Zhuohuan LI <zixia@zixia.net> (http://linkedin.com/in/zixia)
ARM port by Stefan Dimitrov <stefan@dimitrov.li> (https://www.linkedin.com/in/dimitrovs)

<a href="http://stackoverflow.com/users/1123955/zixia">
<img src="http://stackoverflow.com/users/flair/1123955.png" width="208" height="58" alt="profile for zixia at Stack Overflow, Q&amp;A for professional and enthusiast programmers" title="profile for zixia at Stack Overflow, Q&amp;A for professional and enthusiast programmers">
</a>

Copyright & License
-------------------
* Code & Documentation 2015© zixia
* Code released under the Apache 2.0 license
* Docs released under Creative Commons
