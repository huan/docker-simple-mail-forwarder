# Makefile for Simple Mail Forwarder
#
# 	GitHb: https://github.com/huan/docker-simple-mail-forwarder
# 	Author: Huan LI <zixia@zixia.net> https://github.com/huan
#

.PHONY: clean
clean:
	echo clean

.PHONY: version
version:
	@newVersion=$$(awk -F. '{print $$1"."$$2"."$$3+1}' < VERSION) \
		&& echo $${newVersion} > VERSION \
		&& git commit -m "$${newVersion}" > /dev/null \
		&& git tag "v$${newVersion}" \
		&& echo "Bumped version to $${newVersion}"
