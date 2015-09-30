#!/usr/bin/env bats

@test "confirm hostname pretend to work." {
    run hostname any-domain-name
    [ $status = 0 ]
}

@test "confirm hwclock pretend to work." {
    run hwclock any-params
    [ $status = 0 ]
}
