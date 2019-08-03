#!/bin/bash

echo "Updating and Upgrading"
apt-get -q -y update
apt-get install -y -q jq

username=admin

rm -rf /opt/mattermost

if [ "$1" != "" ]; then
    mattermost_version="$1"
else
	echo "Mattermost version is required"
    exit 1
fi

if [ "$2" != "" ]; then
    mattermost_mysql_password="$2"
else
	echo "Mattermost MySQL Password is required"
    exit 1
fi

echo /vagrant/mattermost-$mattermost_version-linux-amd64.tar.gz

if [[ ! -f /vagrant/mattermost-$mattermost_version-linux-amd64.tar.gz ]]; then
	echo "Downloading Mattermost"
	wget -P /vagrant/ https://releases.mattermost.com/$mattermost_version/mattermost-$mattermost_version-linux-amd64.tar.gz
fi

echo "Installing Mattermost"

cp /vagrant/mattermost-$mattermost_version-linux-amd64.tar.gz ./
tar -xzf mattermost*.gz
rm mattermost*.gz
mv mattermost /opt

echo "Configuring Mattermost"

mkdir /opt/mattermost/data
mv /opt/mattermost/config/config.json /opt/mattermost/config/config.orig.json
jq -s '.[0] * .[1]' /opt/mattermost/config/config.orig.json /vagrant/config.json

cat /vagrant/config.json | sed "s/MATTERMOST_MYSQL_PASSWORD/$mattermost_mysql_password/g" > /opt/mattermost/config/config.json
rm /vagrant/config.vagrant.json
ln -s /opt/mattermost/config/config.json /vagrant/config.vagrant.json

mkdir /opt/mattermost/plugins
mkdir /opt/mattermost/client/plugins

useradd --system --user-group mattermost

cp /vagrant/mattermost.service /lib/systemd/system/mattermost.service
systemctl daemon-reload

echo "Setting up users and teams"

cd /opt/mattermost
bin/mattermost user create --email admin@jirademo.com --username "$username" --password admin --system_admin
bin/mattermost user create --email jira@jirademo.com --username jira --password jira42
bin/mattermost team create --name jira-demo --display_name "Jira Demo Team"
bin/mattermost team add jira-demo admin@jirademo.com
bin/mattermost team add jira-demo jira@jirademo.com
bin/mattermost channel create --team jira-demo --name jira-tickets --display_name "Jira Tickets"
bin/mattermost channel add jira-demo:jira-tickets jira admin

# Corrects permissions on the plugins folder
chown -R mattermost:mattermost /opt/mattermost
chmod -R g+w /opt/mattermost

service mysql start
service mattermost start

printf '=%.0s' {1..80}
echo 
echo '                     VAGRANT UP!'
echo "GO TO http://127.0.0.1:8065 and log in with \`$username\`"
echo
printf '=%.0s' {1..80}