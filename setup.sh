#!/bin/bash

apt-get -qq -y update

export DEBIAN_FRONTEND=noninteractive

mysql_root_password=$1
mattermost_mysql_password=$2
jira_mysql_password=$3

echo "Installing MySQL and JRE"

debconf-set-selections <<< "mysql-server-10.0 mysql-server/root_password password $mysql_root_password"
debconf-set-selections <<< "mysql-server-10.0 mysql-server/root_password_again password $mysql_root_password"
apt-get install -y -q mysql-server default-jre
sed -i 's/bind-address/# bind-address/' /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart

echo "Setting up database"

cat /vagrant/root.my.cnf | sed "s/MYSQL_ROOT_PASSWORD/$mysql_root_password/g" > /root/.my.cnf
cat /vagrant/db_setup.sql | sed "s/MATTERMOST_MYSQL_PASSWORD/$mattermost_mysql_password/"\
						  | sed "s/JIRA_MYSQL_PASSWORD/$jira_mysql_password/g"\
						  > ./db_setup.sql
mysql -u root < ./db_setup.sql
rm -rf ./db_setup.sql

################
# INSTALL JIRA #
################

echo "Installing Jira"

jira_version="8.2.4"
jira_archive_name="atlassian-jira-software-$jira_version.tar.gz"
jira_dir="atlassian-jira-software-$jira_version-standalone"

if [ ! -f /vagrant/$jira_archive_name ]; then
	wget "https://product-downloads.atlassian.com/software/jira/downloads/$jira_archive_name" -P /vagrant/
fi
tar -xzf "/vagrant/$jira_archive_name" -C /opt/
mkdir /opt/jira-home

if [ ! -f /vagrant/mysql-connector-java-5.1.47.tar.gz ]; then
	 wget https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-java-5.1.47.tar.gz -P /vagrant/
fi
tar -xzf "/vagrant/mysql-connector-java-5.1.47.tar.gz" -C /opt/

cp /opt/mysql-connector-java-5.1.47/mysql-connector-java-5.1.47.jar "/opt/$jira_dir/lib/"
cp /vagrant/dbconfig.xml /opt/jira-home/
cp /vagrant/web.xml /opt/$jira_dir/conf/web.xml

useradd --system --user-group jira
chown -R jira:jira /opt/jira-home
chown -R jira:jira "/opt/$jira_dir"
export JIRA_HOME=/opt/jira-home

cp /vagrant/jira.service /lib/systemd/system/jira.service
systemctl daemon-reload

service jira start

printf '=%.0s' {1..80}
echo 
echo '                     VAGRANT UP!'
echo "             GO TO http://127.0.0.1:8080"
echo
printf '=%.0s' {1..80}