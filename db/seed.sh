#!/bin/bash
#python3 manage.py seed
mysql -uroot -p$MYSQL_ROOT_PASSWORD --local-infile $MYSQL_DB -e "LOAD DATA INFILE '/products.csv' INTO TABLE LegacySite_product FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n';"
mysql -uroot -p$MYSQL_ROOT_PASSWORD --local-infile $MYSQL_DB -e "LOAD DATA INFILE '/users.csv' INTO TABLE LegacySite_user FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\r\n';"
