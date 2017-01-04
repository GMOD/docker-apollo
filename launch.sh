service postgresql start
service tomcat8 start

#!/bin/bash
until pg_isready; do
	echo -n "."
	sleep 1;
done

echo "Postgres is up, loading chado"
su postgres -c 'createdb apollo'
su postgres -c 'createdb chado'
su postgres -c 'psql -f /apollo/user.sql'

su postgres -c 'PGPASSWORD=apollo psql -U apollo -h 127.0.0.1 chado -f /chado.sql'

cp /apollo/target/apollo*.war ${CATALINA_HOME}/webapps/${CONTEXT_PATH}.war
tail -f ${CATALINA_HOME}/logs/catalina.out
