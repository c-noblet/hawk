#!/bin/bash

. ./path.config

if [[ $1 == "-wp" ]] ; then
  wp = true
  domainName = $2
else 
  domainName = $2
fi

setApacheConf() {
  confString = "<VirtualHost *:80>
  ServerName local.${domainName}
  ErrorLog ${logsPath}/${domainName}/error.log
  CustomLog ${logsPath}/${domainName}/access.log common
  DocumentRoot "${htmlPath}/${domainName}/"
  <Directory ${htmlPath}/${domainName}/>
      Options -Indexes +FollowSymLinks +MultiViews
      AllowOverride All
      Require all granted
  </Directory>
</VirtualHost>"

  echo $confString >> "${a2AvailablePath}/local.${domainName}.conf"

  ln -s "${a2AvailablePath}/local.${domainName}" "${a2EnabledPath}/local.${domainName}.conf"

}

getWordpress() {
  wget -c https://fr.wordpress.org/latest-fr_FR.tar.gz -O "${htmlPath}/wordpress.tar.gz"

  tar -xf "${htmlPath}/wordpress.tar.gz" -C "${htmlPath}/wordpress"

  mv "${htmlPath}/wordpress" "${htmlPath}/${domainName}"

  rm "${htmlPath}/wordpress.tar.gz"
}

setFolders() {
  mkdir "${logsPath}/${domainName}"
  mkdir "${htmlPath}/${domainName}"

  chown -R "${user}:${user}" "${htmlPath}/${domainName}"
  chown -R "${user}:${user}" "${logsPath}/${domainName}"
}

editHostsFile() {
  echo "127.0.0.1        local.${domainName}" >> "/etc/hosts"
}

restartApache() {
  systemctl restart apache2
}

