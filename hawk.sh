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

# Variable and Functions
custom_path="/"
custom_user="user:user"

# Create folders for domain
function setFolders {
  mkdir -p "${custom_path}/${domainName}"

  chown -R "${custom_user}" "${custom_path}/${domainName}"
}

# Add configuration for the new vhost
function setApacheConf {
  echo -e "<VirtualHost *:80>\n
  ServerName local.${domainName}\n
  ErrorLog \${APACHE_LOG_DIR}/error.log\n
  CustomLog \${APACHE_LOG_DIR}/access.log combined\n
  DocumentRoot "${custom_path}/${domainName}/"\n
  <Directory ${custom_path}/${domainName}/>\n
      Options -Indexes +FollowSymLinks +MultiViews\n
      AllowOverride All\n
      Require all granted\n
  </Directory>\n
 </VirtualHost>" > "/etc/apache2/sites-available/local.${domainName}.conf"

  ln -s "/etc/apache2/sites-available/local.${domainName}.conf" "/etc/apache2/sites-enabled/local.${domainName}.conf"
}

# Add configuration for the new node.js vhost
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
  wget -c https://fr.wordpress.org/latest-fr_FR.tar.gz -O "${custom_path}/wordpress.tar.gz"

  tar -xzvf "${custom_path}/wordpress.tar.gz" -C "${custom_path}/${domainName}/"

  rm "${custom_path}/wordpress.tar.gz"

  mv $custom_path/$domainName/wordpress/* $custom_path/$domainName/
  
  rm -R "${custom_path}/${domainName}/wordpress"

  chown -R "www-data:www-data" "${custom_path}/${domainName}/"

  chown -R "${custom_user}" "${custom_path}/${domainName}/wp-content/themes"

  chown "${custom_user}" "${custom_path}/${domainName}"

  chmod -R 777 "${custom_path}/${domainName}"
}

###### Main code ######
domainName="$1"
setFolders

read -e -p "Install for Node.js ? [y/N] " REPLY
if [ $REPLY = "Y" ] || [ $REPLY = "y" ]
then
  setNodeApacheConf
else
  setApacheConf

  read -e -p "Install Wordpress ? [y/N] " REPLY2
  if [ $REPLY2 = "Y" ] || [ $REPLY2 = "y" ]
  then
    getWordpress
  fi
fi

systemctl restart apache2.service

echo "127.0.0.1       local.${domainName}" >> "/etc/hosts"
echo "Your vhost is ready"
