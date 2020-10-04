#!/bin/bash


############################################################
#
#  Description : Apache2 vhost generator
#
#  Auteur : Corentin Noblet
#
#  Date : 30/09/2020
#
###########################################################

# Variable and Function


# Create folders for domain
function setFolders {
  mkdir -p "/home/$USER/logs/${domainName}"
  mkdir -p "/home/$USER/html/${domainName}"

  chown -R "${USER}:${USER}" "/home/$USER/logs/${domainName}"
  chown -R "${USER}:${USER}" "/home/$USER/html/${domainName}"
}

# Add and configuration for the new vhost
function setApacheConf {
  echo -e "<VirtualHost *:80>\n
  ServerName local.${domainName}\n
  ErrorLog /home/$USER/logs/${domainName}/error.log\n
  CustomLog /home/$USER/logs/${domainName}/access.log common\n
  DocumentRoot "/home/$USER/html/${domainName}/"\n
  <Directory /home/$USER/html/${domainName}/>\n
      Options -Indexes +FollowSymLinks +MultiViews\n
      AllowOverride All\n
      Require all granted\n
  </Directory>\n
 </VirtualHost>" > "/etc/apache2/sites-available/local.${domainName}.conf"


  ln -s "/etc/apache2/sites-available/local.${domainName}.conf" "/etc/apache2/sites-enabled/local.${domainName}.conf"

}

# Add a Wordpress service
function getWordpress {
  wget -c https://fr.wordpress.org/latest-fr_FR.tar.gz -O "/home/$USER/html/wordpress.tar.gz"

  tar -xzvf "/home/$USER/html/wordpress.tar.gz" -C "/home/$USER/html/${domainName}/"

  rm "/home/$USER/html/wordpress.tar.gz"
}

###### Main code ######

if [[ "$1" == "-wp" ]]; then
  domainName="$2"
  setFolders
  setApacheConf
  getWordpress
else
  domainName="$1"
  setFolders
  setApacheConf
fi


echo "127.0.0.1        local.${domainName}" >> "/etc/hosts"

echo "Your vhost is ready"
echo -e "Now you can restart Apapche2 with \"systemctl restart apache2.service\""
