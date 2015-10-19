#!/usr/bin/env bats

@test "postfix service installed" {
    [ -x /etc/services.d/postfix/run ]
}
