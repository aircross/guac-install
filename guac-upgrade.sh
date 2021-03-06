VERSION="0.9.11"
SERVER=$(curl -s 'https://www.apache.org/dyn/closer.cgi?as_json=1' | jq --raw-output '.preferred|rtrimstr("/")')

# Stop Tomcat
service tomcat8 stop

# Download and install Guacamole Server
wget ${SERVER}/incubator/guacamole/${VERSION}-incubating/source/guacamole-server-${VERSION}-incubating.tar.gz
tar -xzf guacamole-server-${VERSION}-incubating.tar.gz
cd guacamole-server-${VERSION}-incubating
./configure --with-init-dir=/etc/init.d
make
make install
ldconfig
systemctl enable guacd
cd ..

# Download and replace Guacamole Client
wget ${SERVER}/incubator/guacamole/${VERSION}-incubating/binary/guacamole-${VERSION}-incubating.war
mv guacamole-0.9.11-incubating.war /etc/guacamole/guacamole.war

# Download and upgrade SQL components
wget ${SERVER}/incubator/guacamole/${VERSION}-incubating/binary/guacamole-auth-jdbc-${VERSION}-incubating.tar.gz
tar -xzf guacamole-auth-jdbc-${VERSION}-incubating.tar.gz
cp guacamole-auth-jdbc-${VERSION}-incubating/mysql/guacamole-auth-jdbc-mysql-${VERSION}-incubating.jar /etc/guacamole/extensions/

mysql -u root -p guacamole_db < guacamole-auth-jdbc-${VERSION}-incubating/mysql/schema/upgrade/upgrade-pre-${VERSION}.sql

# Start Tomcat
service tomcat8 start

# Cleanup
rm -rf guacamole*
