Simple Mail Forwarder(SMF) [![Circle CI](https://circleci.com/gh/huan/docker-simple-mail-forwarder/tree/master.svg?style=svg)](https://circleci.com/gh/huan/docker-simple-mail-forwarder/)

==================================

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/zixia/docker-simple-mail-forwarder?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![layers](https://badge.imagelayers.io/zixia/simple-mail-forwarder:latest.svg)](https://imagelayers.io/?images=zixia/simple-mail-forwarder:latest 'Get your own badge on imagelayers.io')
[![Docker Pulls](https://img.shields.io/docker/pulls/zixia/simple-mail-forwarder.svg)](https://hub.docker.com/r/zixia/simple-mail-forwarder/)
![Docker Stars](https://img.shields.io/docker/stars/zixia/simple-mail-forwarder.svg?maxAge=2592000)
[![Docker Repository on Quay.io](https://quay.io/repository/zixia/simple-mail-forwarder/status "Docker Repository on Quay.io")](https://quay.io/repository/zixia/simple-mail-forwarder)

[![dockeri.co](https://dockeri.co/image/zixia/simple-mail-forwarder)](https://hub.docker.com/r/zixia/simple-mail-forwarder/)

Simplest and Smallest Email Forward Service based on Docker.

1. Config by [**one-line**](#environment-variable-and-default)
1. Run as [**docker start**](#quick-start-tldr)
1. Image Size [**10MB**](https://hub.docker.com/r/zixia/simple-mail-forwarder/tags/)

View on Github - https://github.com/huan/docker-simple-mail-forwarder

Voice from Users
------------------------------------

> @Brian Christner : After testing a ton of different mail projects I finally discovered Simple Mail Forwarder (SMF) by Huan. This image is based on Alpine which is already a positive. It is super tiny and as the name suggests, easy to use. [link](https://www.brianchristner.io/setting-up-a-mail-forwarder-in-docker/)

> @kachkaev : really happy to discover it! [link](https://github.com/huan/docker-simple-mail-forwarder/issues/5#issue-165988701)

> @kiani: have a working mail server, seriously, it was that easy. [link](https://kiani.io/blog/custom-domain-mail-forward)

> @counterbeing: great image. Wonderfully easy interface, with all that i need. :+1: [link](https://github.com/huan/docker-simple-mail-forwarder/issues/6#issuecomment-248667232)

> @nelfer: Guess what? Your image already supports this! [link](https://github.com/huan/docker-simple-mail-forwarder/issues/13#issuecomment-255562151)

> @Czocher: It's at least a timesaver if not a lifesaver. [link](https://github.com/huan/docker-simple-mail-forwarder/issues/50#issue-427317446)

What is SMF? (Simple Mail Forwarder)
------------------------------------

If you had a domain name and only wanted to have one(or a few) email address from this domain, but you want to forward all the emails to another email account. SMF is exactly what you need. (with [Docker](http://docker.com))

This docker image was built for ultimate **simplicity** because of this reason. I owned many domains and needed email addresses of them(for fun/work), and I hated to config email server. Some DNS providers provide free email forwarding service for their own domain, some do not. And almose all email forwarding service is NOT free. So I decided to make it myself(thanks docker).

### Related Services

- [DuoCircle Email Forwarding](http://www.duocircle.com/services/email-forwarding) From $59.95/year
- [Cloud Mail In](https://www.cloudmailin.com/plans) From $9/month. And it is not for human.
- [MailGun](https://mailgun.com) professional service. Free plan includes 10,000 emails/month. but [can result in your domain being treated as spam](https://blog.rajivm.net/mailgun-forwarding-spam.html)

I was willing to pay $10/year, but the cheapest plan I could find was $9 per month. Having a $10 USD machine with unlimited mail&domains per month is an amazing idea! And of course you could also put other dockers on this same machine. :-D

Quick Start (TL;DR)
-------------------

Just set `SMF_CONFIG` and run:

```bash
export SMF_CONFIG='testi@testo.com:test@test.com:test'
docker run -e SMF_CONFIG="$SMF_CONFIG" -p 25:25 zixia/simple-mail-forwarder
```

> Don't forget to modify the DNS MX record of your domain. (in this example, it's _testo.com_)

This will forward all emails received by testi@testo.com to test@test.com.

If you want to forward all emails sent to domain testo.com to all@test.com, set it like so:

```bash
export SMF_CONFIG='@testo.com:all@test.com'
```

See? There is nothing easier.

> If you want to run it constanly in the background add `-t -d --restart=always` after `run`:

```bash
docker run -t -d --restart=always -e SMF_CONFIG="$SMF_CONFIG" -p 25:25 zixia/simple-mail-forwarder
```

- `-t`: Allocate a pseudo-tty
- `-d`: Detached Mode
- `--restart=always`: Restart this container automatically

Otherwise, docker thinks that your applications stops and shutdown the container.

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

`SMF_CONFIG`: MUST be defined. no default setting. (set me! I'm the only parameter you need to set~)

`TZ` : (Optional) set the timezone , IE `EST5EDT` or `Europe/Rome`

### `SMF_CONFIG` Examples

Here's how to config the only required `SMF_CONFIG` environment parameter of SMF Docker:

#### 1. Basic

Forward all emails received by testi@testo.com to test@test.com:

```bash
export SMF_CONFIG='testi@testo.com:test@test.com'
```

Forward all emails received by any email address in domain testo.com to all@test.com:

```bash
export SMF_CONFIG='@testo.com:all@test.com'
```

> You could get the ESMTP AUTH password for you on your docker log. It's randomly generated if you do not provide one.

#### 2. Advanced

Add ESMTP AUTH password:

```bash
export SMF_CONFIG='from@testi.com:to@testo.com:ThisIsPassword'
```

> Password will be printed on the docker log.

#### 3. Hardcore

Add as many email accounts as you want, with or without password. Seperated by semicolon or a new line:

```bash
export SMF_CONFIG='testi@testo.com:test@test.com:ThisIsPassword;testo@testi.com:test@test.com:AnotherPassword'
```

> Tips: if you only provide the first password and leave the rest blank, then the passwords for all the rest accounts will be the same as the last password value you set. This is by design.

You can also forward all emails received by testi@testo.com to multiple destination addresses:

```bash
export SMF_CONFIG='testi@testo.com:test1@test.com|test2@test.com|test3@test.com'
```

### `SMF_RELAYHOST` Examples

Here's howto config a relayhost/smarthost to use for forwarding mail.

Send all outgoing mail trough a smarthost on 192.168.1.2

```bash
export SMF_RELAYHOST='192.168.1.2'
```

TLS (SSL) Certificates
--------------------

SMF creates its own certificate and private key when starts. However, this certificate is self signed and so some systems might give you a warning about the server not being trusted.
If you have valid certificates for the domain name of the host, then you can use them and avoid the warning about not being trusted.

1. First you need to prepare the certificate files. Copy your full chain certificate to a file named `smtp.cert` (or `smtp.ec.cert` if it contains a EC certificate). Then copy the private key to a file named `smtp.key` (or `smtp.ec.key` if it contains a EC key)

2. Copy these files to a folder. For example: `/data/certs/`. This folder will be mounted as a volume in SMF

3. When creating the container, add the `-v` (volume) parameter to mount it to the folder `/etc/postfix/cert/` like so:

    ```bash
    docker run  -e SMF_CONFIG="$SMF_CONFIG" -p 25:25 -v /data/certs/:/etc/postfix/cert/ zixia/simple-mail-forwarder
    ```

4. Your emails should now be forwarded with trusted encryption. You can use this tool to test it: <a href="http://checktls.com/" target="_blank">http://checktls.com/</a>

If you do not have a certificate and don't have the $$ to buy one, you can use <a href="https://letsencrypt.org" target="_blank">https://letsencrypt.org</a> if you have shell access to the server (Notice, SMF does not provide, yet, this service). Letsencrypt allows you to create valid trusted certificates for a server, if the server responds to the domain you specify. In order to do this, you need to run the program from within the server and have administrator rights.

1. First install letsencrypt. This might vary by distribution, but in Ubuntu it is like this:

    ```bash
    sudo apt-get install letsencrypt
    ```

1. Stop any web server that might be using port 80 (Apache, nginx, etc)
1. Determine all of the domains and subdomains that you want the certificate to cover, for example `mydomain.com`, `www.mydomain.com`, `smtp.mydomain.com`, etc. Remember to include the domain that SMF will respond to (as per MX record in DNS configuration of the domain)
1. Execute the following command (you can add as many domains as you wish with the `-d` option. But remember, their DNS resolution must resolve to the server where `letsencrypt` is being executed)

    ```bash
    letsencrypt certonly --standalone -d yourdomain.com -d www.yourdomain.com -d mail.yourdomain.com
    ```

1. Follow the prompts and if everything is successful you will get your certificates in a folder like `/etc/letsencrypt/live/mydomain.com`
1. You can now use those certificates to make SMF TLS trusted.

> This was a quick way of how to use letsencrypt. For a full tutorial based on your OS see: <a href="https://certbot.eff.org/" tareget="_blank">https://certbot.eff.org/</a>

Helper Scripts
--------------------

1. Build from source.

    ```bash
    ./script/build.sh latest
    ```

1. Run a self-test for SMF docker.

    ```bash
    ./script/run.sh latest test
    ```

1. Get a shell inside SMF docker.

    ```bash
    ./script/devshell.sh latest
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
Github Issue - https://github.com/huan/docker-simple-mail-forwarder/issues

Changelog
---------

### master

### v1.1 (09 Jun 2019)

1. Timezone support by @me1299 [#56](https://github.com/huan/docker-simple-mail-forwarder/issues/56) [#57](https://github.com/huan/docker-simple-mail-forwarder/pull/57)
1. EC key support by @Czocher [#51](https://github.com/huan/docker-simple-mail-forwarder/pull/51)
1. Upgrade CircleCI from v1 to v2 @huan
1. Fix typo in README @universeroc [#47](https://github.com/huan/docker-simple-mail-forwarder/pull/47)
1. Update Base to Alpine 3.8 @riptidewave93 [#43](https://github.com/huan/docker-simple-mail-forwarder/pull/43)
1. Update alpine:latest as base image @martijnrondeel [#37](https://github.com/huan/docker-simple-mail-forwarder/pull/37)

### v1.0.0 (25 Jul 2017)

* Release v1.0

### v0.4.3 (14 Jul 2017)

1. Add a note about running it in the background to prevent docker auto shutdown. by @delmicio [#27](https://github.com/huan/docker-simple-mail-forwarder/pull/27)
1. Added smarthost support by @Duumke [#22](https://github.com/huan/docker-simple-mail-forwarder/pull/22)
1. Added support for mynetworks by @SamMousa [#20](https://github.com/huan/docker-simple-mail-forwarder/issues/20)
1. Allow own certificates by @nelfer [#15](https://github.com/huan/docker-simple-mail-forwarder/pull/15)
1. Updated documentation for forward all emails @nelfer [#14](https://github.com/huan/docker-simple-mail-forwarder/pull/14)
1. ARM version of armhf by @dimitrovs [#12](https://github.com/huan/docker-simple-mail-forwarder/pull/12)
1. use SMF_DOMAIN env for certificate's CN by @bcardiff [#11](https://github.com/huan/docker-simple-mail-forwarder/pull/11)
1. allow multiple forwards separated by | by @kminek [#7](https://github.com/huan/docker-simple-mail-forwarder/pull/7)
1. Update docker-compose.yml to fix tutum tag by @vegasbrianc [#4](https://github.com/huan/docker-simple-mail-forwarder/pull/4)

### v0.4.2 (25 Sep 2016)

1. close issue #1
1. increace message size limit from 10MB to 40MB
1. fix domain name in scripts
1. fix unit test fail error: do not upgrade alpine
1. restore deploy button in reamde: it is docker cloud now.(former tutum)

### v0.4.0

1. switch FROM image from alpine to [sillelien/base-alpine](https://github.com/sillelien/base-alpine)
 1. manage postfix service by [S6](http://skarnet.org/software/s6/)
 1. [solve PID 1 Zombie Problem](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/)
 1. enhanced busybox shell
1. NOT to use OpenRC(very buggy run inside docker container) any more!
1. better ESMTP TLS AUTH test script
1. docker image size: [10MB](https://hub.docker.com/r/zixia/simple-mail-forwarder/tags/)

### ~~v0.3.0~~ <- Don't use me, I'm BUGGY

1. CI(continuous integration) supported by use [CircleCI](https://circleci.com)
1. CD(continuous delivery) supported by use [Tutum Button](https://support.tutum.co/support/solutions/articles/5000620449-deploy-to-tutum-button)
1. write better tests
1. tune OpenRC inside alpine linux
1. full description README
1. docker image size: [7MB](https://hub.docker.com/r/zixia/simple-mail-forwarder/tags/)

### ~~v0.2.0~~ <- Don't use me, I'm BUGGY

1. supported specify user password
1. supported ESMTP TLS
1. docker image size: [7MB](https://hub.docker.com/r/zixia/simple-mail-forwarder/tags/)

### v0.1.0

1. dockerized
1. basic forward function
1. self-testing
1. docker image size: [6MB](https://hub.docker.com/r/zixia/simple-mail-forwarder/tags/)

Cloud Requirement
-----------------
* A Cloud Service that could host docker is required.
  * [DigitalOcean.com](https://m.do.co/c/01a54778df5c) get $10 free credit(cover 2 months vpsv cost) by register from here.
  * [LiNode.com](https://www.linode.com/?r=5fd2b713d711746bb5451111df0f2b6d863e9f63)
  * [Netdedi](http://www.netdedi.com/?affid=35) SSD VPS and Dedicated Server with NetDedi(Koera)

* A Docker management platform is recommanded.
  * Docker Cloud(Former Tutum) [![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy)
* Docker is required.
  * Docker.com

## AUTHOR

[Huan LI (李卓桓)](http://linkedin.com/in/zixia) <zixia@zixia.net>

[![Profile of Huan LI (李卓桓) on StackOverflow](https://stackexchange.com/users/flair/265499.png)](https://stackexchange.com/users/265499)

## COPYRIGHT & LICENSE

- Code & Docs © 2015 - now Huan LI <zixia@zixia.net>
- Code released under the Apache-2.0 License
- Docs released under Creative Commons
