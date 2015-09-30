#!/usr/bin/env bats

@test "confirm hostname pretend to work." {
    run service hostname start
    [ $status = 0 ]
}

@test "confirm hwclock pretend to work." {
    run hwclock any-params
    [ $status = 0 ]
}
