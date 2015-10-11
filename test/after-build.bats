#!/usr/bin/env bats

@test "confirm openrc conf set to lxc" {
    # sed -i '/rc_sys/ c\rc_sys="lxc"' /etc/rc.conf \
    n=$(grep ^rc_sys /etc/rc.conf | grep lxc | wc -l)

    [ $n -gt 0 ]
}

@test "service postfix could start/stop right." {
    run service postfix status

    wasRunning=false

    # we save postfix service stat at start, so we could restore at end
    if [[ $output =~ started ]]
    then
        wasRunning=true
        service postfix stop
    fi

    run service postfix start
    [ $status = 0 ]
    [[ $output =~ "Starting postfix  ..." ]]

    run service postfix start
    [ $status = 0 ]
    [[ ${lines[0]} =~ "WARNING: postfix has already been started" ]]

    processNum=$(ps | grep -v grep | grep /usr/lib/postfix/master | wc -l)
    [ $processNum -gt 0 ]

    run netstat -nlt
    [ $status = 0 ]
    [[ $output =~ ":25 " ]]

    run service postfix stop
    [ $status = 0 ]
    [[ $output =~ "Stopping postfix  ..." ]]

    run service postfix stop
    [ $status = 0 ]
    [[ $output =~ "WARNING: postfix is already stopped" ]]

    # we restore postfix at the end
    if $wasRunning
    then
        run service postfix start
        [ $status = 0 ]
        [[ $output =~ "Starting postfix  ..." ]]
    fi
}

@test "cgroups disabled" {
    output=$(grep rc_controller_cgroups /etc/rc.conf | grep NO)
    [[ $output =~ NO ]]

    output=$(grep cgroup_add_service /lib/rc/sh/openrc-run.sh | grep DISABLED)
    [[ $output =~ DISABLED ]]
}
