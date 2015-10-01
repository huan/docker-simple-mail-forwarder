#!/usr/bin/env bats

@test "confirm hostname pretend to work." {
    run service hostname start
    [ $status = 0 ]
}

@test "confirm hwclock pretend to work." {
    run hwclock any-params
    [ $status = 0 ]
}

@test "service postfix could start/stop right." {
    run service postfix stop

    run service postfix start
    [ $status = 0 ]
    [[ ${lines[0]} =~ "Starting postfix  ..." ]]

    run service postfix start
    [ $status = 0 ]
    [[ ${lines[0]} =~ "WARNING: postfix has already been started" ]]

    run service postfix stop
    [ $status = 0 ]
    [[ $output =~ "Stopping postfix  ..." ]]

    run service postfix stop
    [ $status = 0 ]
    [[ $output =~ "WARNING: postfix is already stopped" ]]
}

@test "service syslog could start/stop right." {
    run service syslog stop

    run service syslog start
    [ $status = 0 ]
    [[ $output =~ "Starting busybox syslog" ]]

    run service syslog start
    [ $status = 0 ]
    [[ ${lines[0]} =~ "WARNING: syslog has already been started" ]]

    run service syslog stop
    [ $status = 0 ]
    [[ $output =~ "Stopping busybox syslog" ]]

    run service syslog stop
    [ $status = 0 ]
    [[ $output =~ "WARNING: syslog is already stopped" ]]
}
