#!/bin/bash
  
user=$NB_USER

mysql -u root -padmin -e "CREATE USER '$user'@'%' IDENTIFIED BY 'pluralcamp'; GRANT ALL PRIVILEGES ON *.* TO '$user'@'%'; FLUSH PRIVILEGES;";
