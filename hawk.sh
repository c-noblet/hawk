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
custom_path=""

# Create folders for domain
function setFolders {
  mkdir -p "${custom_path}/${domainName}"

  chown -R "${USER}:${USER}" "${custom_path}/${domainName}"
}

# Add and configuration for the new vhost
function setApacheConf {
  echo -e "<VirtualHost *:80>\n
  ServerName local.${domainName}\n
  ErrorLog ${APACHE_LOG_DIR}/error.log\n
  CustomLog ${APACHE_LOG_DIR}/access.log combined\n
  DocumentRoot "${custom_path}/${domainName}/"\n
  <Directory ${custom_path}/${domainName}/>\n
      Options -Indexes +FollowSymLinks +MultiViews\n
      AllowOverride All\n
      Require all granted\n
  </Directory>\n
 </VirtualHost>" > "/etc/apache2/sites-available/local.${domainName}.conf"

  ln -s "/etc/apache2/sites-available/local.${domainName}.conf" "/etc/apache2/sites-enabled/local.${domainName}.conf"
}

# Add and configuration for the new vhost for node.js
function setNodeApacheConf {
  echo -e "<VirtualHost *:80>\n
    ServerName local.${domainName}\n
    ErrorLog ${APACHE_LOG_DIR}/error.log\n
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n
    ProxyRequests Off\n
    ProxyPreserveHost On\n
    ProxyVia Full\n
    <Proxy *>\n
      Require all granted\n
    </Proxy>\n

    <Location ${custom_path}/${domainName}/>\n
      ProxyPass http://127.0.0.1:8080\n
      ProxyPassReverse http://127.0.0.1:8080\n
    </Location>\n

    <Directory ${custom_path}/${domainName}/>\n
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

  tar -xzvf "/${custom_path}/wordpress.tar.gz" -C "/${custom_path}/${domainName}/"

  rm "/${custom_path}/wordpress.tar.gz"
}

###### Main code ######
  domainName="$1"
  setFolders
  
  read -p "Install for Node.js" -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    setNodeApacheConf
  else
	  setApacheConf
  fi
  
  read -p "Install Wordpress ? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    getWordpress
  fi

  systemctl restart apache2.service

echo "127.0.0.1        local.${domainName}" >> "/etc/hosts"
echo "Your vhost is ready"
