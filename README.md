# Hawk

Hawk is an apache2 vhost generator. It can generate vhosts by giving it a domain name and you can also choose to create a Wordpress project.

/!\ Be aware that this program was developed for my personal needs.

## Installation

Create a path.config file at the project root with the path to your home and your username :

```bash
# path.config

htmlPath = "/home/<Me>/html",
logsPath = "/home/<Me>/logs",
user = "<Me>",
hostsPath = "/etc/hosts",
a2AvailablePath = "/etc/apache2/sites-available",
a2EnabledPath = "/etc/apache2/sites-enabled"
 ```

## Upgrades to do

* Wordpress auto wp-config.php updater
* Wordpress auto database configuration
