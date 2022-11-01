-- SQL script to initialize the DB
-- The docker container will use any ip of the range of the public subnet (10.0.1.0/24) to connect to the DB
CREATE USER 'user'@'$10.0.1.%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'user'@'$10.0.1.%';
FLUSH PRIVILEGES;
CREATE DATABASE photosdb;
USE photosdb;
CREATE TABLE photos (id mediumint(8) unsigned NOT NULL auto_increment,name varchar(255) default NULL,price varchar(255) default NULL, image_url varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
INSERT INTO photos (name,price,image_url) VALUES ("Tohoku","100","Japan-1.jpg"),("Osaka","200","Japan-2.jpg"),("Senso-ji","300","Japan-3.jpg"),("Shibuya","50","Japan-4.jpg"),("Fuji reflection","90","Japan-5.jpg"),("Fuji sunrise","20","Japan-6.jpg"),("Kyoto","80","Japan-7.jpg"),("Hiroshima","150","Japan-8.jpg"),("Miyajima","150","Japan-9.jpg"),("Gozanoishi Shrine","150","Japan-10.jpg"),("Cold mountains","150","Japan-11.jpg"),("Warm mountains","150","Japan-12.jpg");



-- #TODO Database should still be setup with proper user for the docker process to access
-- #TODO do it in setup.db.sql
-- # [ec2-user@ip-10-0-1-221 log]$ sudo /usr/bin/docker run -t -p 800:9000 -e DATABASE_URL=terraform-20221101120402844300000002.c5pcsgq6i2fl.ap-northeast-1.rds.amazonaws.com awoisoak/photo-shop
-- # Database URL:  terraform-20221101120402844300000002.c5pcsgq6i2fl.ap-northeast-1.rds.amazonaws.com
-- #  * Serving Flask app 'app'
-- #  * Debug mode: off
-- # WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
-- #  * Running on all addresses (0.0.0.0)
-- #  * Running on http://127.0.0.1:9000
-- #  * Running on http://172.17.0.3:9000
-- # Press CTRL+C to quit
-- # Error connecting to the db :(

-- # Access denied for user 'root'@'10.0.1.221' (using password: YES)