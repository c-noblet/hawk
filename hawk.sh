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


