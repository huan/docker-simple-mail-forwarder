# Simple Mail Forwarder (SMF)

This is a fork of huan/docker-simple-mail-forwarder that adds the `SMF_POSTFIX_*` variable as documented below.



What is Simple Mail Forwarder (SMF)?
------------------------------------

If you have a domain name, only want to have one (or a few) email address(es) on this domain, and you want to forward all the emails to another email account - **Simple Mail Forwarder (SMF)** is exactly what you need. (with [Docker](http://docker.com))


Quick-start (TL;DR)
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
$ docker run knipknap/docker-simple-mail-forwarder test
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

`SMF_CONFIG`: MUST be defined. there's no default setting. (set me! I'm the only parameter you need to set~)

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

Here's how to configure a relayhost/smarthost to use for forwarding mail.

Send all outgoing mail trough a smarthost on 192.168.1.2

```bash
export SMF_RELAYHOST='192.168.1.2'
```

### `SMF_RELAYAUTH` Examples

If the `SMF_RELAYHOST` require authentication,

```bash
export SMF_RELAYAUTH='username@relayhost.com:RelayHostPassword'
```

### `SMF_POSTFIX_*` Examples

To provide a generic way to customize Postfix configuration, you can use environment variables 
prefixed with `SMF_POSTFIX_`:

```bash
export SMF_POSTFIX_myhostname=smtp.domain1.com
```

This will cause SMF to execute the following command before starting up:

```bash
postconf -e "myhostname=smtp.domain1.com"
```


TLS (SSL) Certificates
--------------------

SMF creates its own certificate and private key when it starts. This certificate is self signed, so some systems might give you a warning about the server not being trusted.
If you have valid certificates for the domain name of the host, then you can use them and avoid the warning about not being trusted.

1. First you need to prepare the certificate files. Copy your full chain certificate to a file named `smtp.cert` (or `smtp.ec.cert` if it contains a EC certificate). Then copy the private key to a file named `smtp.key` (or `smtp.ec.key` if it contains a EC key)

2. Copy these files to a folder. For example: `/data/certs/`. This folder will be mounted as a volume in SMF

3. When creating the container, add the `-v` (volume) parameter to mount it to the folder `/etc/postfix/cert/` like so:

    ```bash
    docker run  -e SMF_CONFIG="$SMF_CONFIG" -p 25:25 -v /data/certs/:/etc/postfix/cert/ zixia/simple-mail-forwarder
    ```

4. Your emails should now be forwarded with trusted encryption. You can use this tool to test it: <a href="http://checktls.com/" target="_blank">http://checktls.com/</a>

If you do not have a certificate and don't have the budget to afford one, you can use <a href="https://letsencrypt.org" target="_blank">https://letsencrypt.org</a> if you have shell access to the server (Note, SMF does not provide this service, yet). Letsencrypt allows you to create valid trusted certificates for a server, if the server responds to the domain you specify. In order to do this, you need to run the program from within the server and have administrator rights.

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


## COPYRIGHT & LICENSE

- Code & Docs © 2015 - now Huan LI <zixia@zixia.net>
- Code released under the Apache-2.0 License
- Docs released under Creative Commons
