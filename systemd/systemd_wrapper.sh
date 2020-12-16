#!/usr/bin/env bash

trap 'kill $(jobs -p)' EXIT

service="vpn"
PID=$$
PIDFILE=/var/run/seedbox-docker-downloader.pid

echo "$PID" > "$PIDFILE"
docker-compose up -d &
systemd-notify --ready --status=Started

notify_success () {
    if [[ ! -f "$PIDFILE" ]]; then
	echo "$PID" > "$PIDFILE"
    fi
    systemd-notify --pid $PID --status="$1" WATCHDOG=1
    echo "$1"
}

notify_failure () {
    if [[ -f "$PIDFILE" ]]; then
        rm -f $PIDFILE
    fi
    systemd-notify --status="$1"
    echo "$1"
}

while [ 1 ] ; do
    sleep 30

    container_id=$(docker-compose --log-level ERROR --project-directory /opt/seedboxio-docker-downloader ps -q "$service")
    if [[ "$container_id" == "" ]]; then
        notify_failure "Down"
	continue
    fi

    health_status=$(docker inspect -f "{{.State.Health.Status}}" "$container_id")

    if [[ "$health_status" == "starting" ]]; then
	notify_success "Waiting for healthcheck"
	continue
    fi

    if [[ "$health_status" == "healthy" ]]; then
        notify_success "Healthy"
	continue
    fi

    notify_failure "Unhealthy"
done

if [[ -f "$PIDFILE" ]]; then
    rm -f $PIDFILE
fi

