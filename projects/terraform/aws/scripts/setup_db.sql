-- SQL script to initialize the DB
-- The docker container will use any ip of the range of the public subnet (10.0.1.0/24) to connect to the DB
-- CREATE USER 'user'@'$10.0.1.%' IDENTIFIED BY 'password';
-- GRANT ALL PRIVILEGES ON *.* TO 'user'@'$10.0.1.%';
-- FLUSH PRIVILEGES;
CREATE DATABASE photosdb;
USE photosdb;
CREATE TABLE photos (id mediumint(8) unsigned NOT NULL auto_increment,name varchar(255) default NULL,price varchar(255) default NULL, image_url varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
INSERT INTO photos (name,price,image_url) VALUES ("Tohoku","100","Japan-1.jpg"),("Osaka","200","Japan-2.jpg"),("Senso-ji","300","Japan-3.jpg"),("Shibuya","50","Japan-4.jpg"),("Fuji reflection","90","Japan-5.jpg"),("Fuji sunrise","20","Japan-6.jpg"),("Kyoto","80","Japan-7.jpg"),("Hiroshima","150","Japan-8.jpg"),("Miyajima","150","Japan-9.jpg"),("Gozanoishi Shrine","150","Japan-10.jpg"),("Cold mountains","150","Japan-11.jpg"),("Warm mountains","150","Japan-12.jpg");