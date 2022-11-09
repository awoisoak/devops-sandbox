-- Configuring Database
-- CREATE DATABASE photosdb;
-- CREATE USER 'user'@'localhost' IDENTIFIED BY 'password';
-- GRANT ALL PRIVILEGES ON *.* TO 'user'@'localhost';
-- FLUSH PRIVILEGES;

-- Loading data
-- USE photosdb; Not needed since docker will use by default the one passed through MARIADB_DATABASE env
CREATE TABLE photos (id mediumint(8) unsigned NOT NULL auto_increment,name varchar(255) default NULL,price varchar(255) default NULL, image_url varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
INSERT INTO photos (name,price,image_url) VALUES ("Tohoku","100","Japan-1.jpg"),("Osaka","200","Japan-2.jpg"),("Senso-ji","300","Japan-3.jpg"),("Shibuya","50","Japan-4.jpg"),("Fuji reflection","90","Japan-5.jpg"),("Fuji sunrise","20","Japan-6.jpg"),("Kyoto","80","Japan-7.jpg"),("Hiroshima","150","Japan-8.jpg"),("Miyajima","150","Japan-9.jpg"),("Gozanoishi Shrine","150","Japan-10.jpg"),("Cold mountains","150","Japan-11.jpg"),("Warm mountains","150","Japan-12.jpg");
