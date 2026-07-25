#!/bin/bash

install()
{
    echo 'start install nebula.....'
	echo `docker-compose down `
	
	echo `docker-compose up -d `
	
	echo 'import db data.....'
	sleep 15
	nebula_db_id=`docker ps | grep -w 'nebula-db' | awk '{print $1}'`
	echo 'run id:' $nebula_db_id
	echo `docker cp ./scripts/db/initdb.sh $nebula_db_id:/tmp/initdb.sh`
    echo `docker cp ./scripts/db/nebula.init.data.sql $nebula_db_id:/tmp/nebula.init.data.sql`
	echo `docker-compose exec nebula-db bash /tmp/initdb.sh`
	sleep 5
    echo `docker-compose down`
    echo 'done.'
}

start()
{
	echo 'start nebula.....'
	echo `docker-compose up -d `
}

stop()
{
	echo 'stop nebula.....'
	echo `docker-compose down `
}

status()
{
	docker-compose ps
    docker-compose exec nebula supervisorctl status
}

case "$1" in
start)
    start
    ;;
stop)
    stop
    ;;
status)
    status
    ;;
restart)
     stop
     start
     ;;
install)
     install
     ;;
*)
    echo "Usage: $0 {start|restart|stop}"
    exit 1
    ;;
esac


