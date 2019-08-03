# -*- mode: ruby -*-
# vi: set ft=ruby :
MATTERMOST_VERSION = '5.13.1'
MYSQL_ROOT_PASSWORD = 'secure_root_password'
MATTERMOST_MYSQL_PASSWORD = 'really_secure_password'
JIRA_MYSQL_PASSWORD = 'really_secure_password'

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
  config.vm.provider "virtualbox" do |v|
	v.memory = 4096
	v.cpus = 2
  end
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 8065, host: 8065
  config.vm.network "forwarded_port", guest: 3306, host: 13306
  config.vm.hostname = 'mattermost-jira'

  config.vm.provision :shell, path: 'setup.sh', args: [MYSQL_ROOT_PASSWORD, MATTERMOST_MYSQL_PASSWORD, JIRA_MYSQL_PASSWORD]
  config.vm.provision :shell, path: 'mattermost_setup.sh', args: [MATTERMOST_VERSION, MATTERMOST_MYSQL_PASSWORD]
end