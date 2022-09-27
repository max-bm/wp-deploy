# wp-deploy: a scripted deployment of wordpress on CentOS 8.
A script born from the frustration of having to deploy wordpress manually far too many times.

Execute the script (you may need superuser privileges):

<code>./deploy.sh [URL] [PASSWORD] [--mysql]</code>

The <code>URL</code> argument is the domain name or IP address at which the site will be deployed. You should omit leading http:// or https:// from the URL.

The <code>PASSWORD</code> argument is the password of your wordpress database. If your database is already configured, use the password previously set. If the database is to be configured by the script, this argument will set it.

The <code>--mysql</code> option will install and configure your mysql database if enabled.
