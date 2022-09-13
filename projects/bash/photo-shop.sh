#!/bin/bash
#
# Photo-shop application deployment automation

#######################################
# Prints a text in a given color.
# Arguments: 
#     $1 Color ('green' or 'red')
#     $2 Message to be printed
#######################################
function print_color(){
  NC='\033[0m' # No Color
  case $1 in
    "green") COLOR='\033[0;32m' ;;
    "red") COLOR='\033[0;31m' ;;
    "*") COLOR='\033[0m' ;;
  esac
  echo -e "${COLOR} ${@:2} ${NC}"
}

#######################################
# Print the passed text in green.
#######################################
function success(){
  print_color "green" "$@"
}

#######################################
# Print the passed text in red.
#######################################
function fail(){
  print_color "red" "$@"
}

#######################################
# Check the status of a given service. If not active it will exit the script
# Arguments: 
#     $1 Service name (eg: httpd, mariadb..)
#######################################
function check_service_status(){
  service_is_active=$(sudo systemctl is-active $1)

  if [ $service_is_active = "active" ]
  then
    success "$1 is active and running ;)"
  else
    fail "$1 is not active, aborting script... :("
    exit 1
  fi
}

#######################################
# Check if a certain text is part of a given one
# Arguments:
#     $1 - Output
#     $2 - Item
#######################################
function check_item(){
  if [[ $1 = *$2* ]]
  then
    success "Item $2 is present"
  else
    fail "Item $2 is not present"
  fi
}

success "############## Setup Database Server... ##############"
# Update list of available packages
sudo apt update

# Install and configure Maria-DB
success "Installing MariaDB Server.."
sudo apt install mariadb-server -y

success "Starting MariaDB Server.."
sudo service mariadb start
sudo systemctl enable mariadb

# Check Mariadb Service is running
check_service_status mariadb

# Configuring Database
success "Setting up database.."
cat > setup-db.sql <<-EOF
  CREATE DATABASE photodb;
  CREATE USER 'user'@'localhost' IDENTIFIED BY 'password';
  GRANT ALL PRIVILEGES ON *.* TO 'user'@'localhost';
  FLUSH PRIVILEGES;
EOF

sudo mysql < setup-db.sql

# Loading inventory into Database
success "Loading inventory data into database"
cat > db-load-script.sql <<-EOF
  USE photodb;
  CREATE TABLE photos (id mediumint(8) unsigned NOT NULL auto_increment,name varchar(255) default NULL,price varchar(255) default NULL, image_url varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
  INSERT INTO photos (name,price,image_url) VALUES ("Tohoku","100","Japan-1.jpg"),("Osaka","200","Japan-2.jpg"),("Senso-ji","300","Japan-3.jpg"),("Shibuya","50","Japan-4.jpg"),("Fuji reflection","90","Japan-5.jpg"),("Fuji sunrise","20","Japan-6.jpg"),("Kyoto","80","Japan-7.jpg"),("Hiroshima","150","Japan-8.jpg"),("Miyajima","150","Japan-9.jpg"),("Gozanoishi Shrine","150","Japan-10.jpg"),("Cold mountains","150","Japan-11.jpg"),("Warm mountains","150","Japan-12.jpg");
EOF

sudo mysql < db-load-script.sql

mysql_db_results=$(sudo mysql -e "use photodb; select * from photos;")

if [[ $mysql_db_results == *Japan* ]]
then
  success "Photos loaded into MySQl"
else
  success "Photos not loaded into MySQl"
  exit 1
fi


success "############## Setup Database Server... DONE ##############"

success "############## Setup Web Server... ##############"
# Install web server packages
success "Installing Web Server Packages .."
# sudo yum install -y httpd php php-mysql

success "Installing Python Packages .."
sudo apt install python3 python3-pip -y
success "Installing Mysql Client Packages .."
sudo apt install mysql-client-8.0 libmysqlclient-dev -y
success "Installing curl .."
sudo apt install curl -y

# Start Python Flask web server

#Install git
success "Installing git.."
sudo apt install git -y

# Download code
success "Downloading source code and setting it up..."
sudo git clone https://github.com/awoisoak/photo-shop.git /var/www/html/

# Set localhost as the database host 
sudo sed -i 's/INSERT_DB_ADDRESS/localhost/g' /var/www/html/modules/repo.py

# Move to working directoy
cd /var/www/html

# Install Python dependencies 
pip install -r /var/www/html/requirements.txt

success "############## Setup Web Server... DONE ##############"

# Run web server
success "Starting web server.."
python3 app.py&

# Check whether the web server contains the expected objects
page=$(curl http://localhost:9000)

for item in Japan-1 Japan-2 Japan-3
do
  check_item "$page" $item
done