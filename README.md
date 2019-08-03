# Mattermost Jira Test Server

This sets up Mattermost and Jira servers to demo the Mattermost Jira plugin.

## Server Setup

1. Run `vagrant up`
2. Go to `http://127.0.0.1:8080` and set up Jira
3. Go to `http://127.0.0.1:8065` and log in with `admin/admin`

## Connecting to the server

### Web Interface:

 - **Mattermost:** [http://127.0.0.1:8065](http://127.0.0.1:8065)
 	- **Username:** admin
 	- **Password:** admin

 - **Jira:** [http://127.0.0.1:8080](http://127.0.0.1:8080)

### SSH

 - `vagrant ssh`

### MySQL

 - Configure your local client like this:
 	- Mattermost Database
 		- **Host:** `127.0.0.1`
 		- **Username:** `mmuser`
 		- **Password:** `really_secure_password`
 		- **Database:** `mattermost`
 		- **Port:** `13306`
 	- Jira Database
 		- **Host:** `127.0.0.1`
 		- **Username:** `jira`
 		- **Password:** `really_secure_password`
 		- **Database:** `mattermost`
 		- **Port:** `13306`

## Configuring the Jira plugin

1. Go to Settings Menu > System, then click Webhooks
2. Create a Webhook with these values:

3. Install Jira in the Mattermost server by running this slash command and following the instructions displayed

```
/jira install server http://127.0.0.1:8080
```

4. Connect to your Jira account by running this slash command and clicking the link created:

```
/jira connect
```