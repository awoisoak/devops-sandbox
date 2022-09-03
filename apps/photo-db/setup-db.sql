-- Configuring Database
-- CREATE DATABASE photosdb;
-- CREATE USER 'user'@'localhost' IDENTIFIED BY 'password';
-- GRANT ALL PRIVILEGES ON *.* TO 'user'@'password';
-- FLUSH PRIVILEGES;

-- Loading data
-- USE photosdb; Not needed since docker will use by default the one passed through MARIADB_DATABASE env
CREATE TABLE photos (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
INSERT INTO photos (Name,Price,ImageUrl) VALUES ("Tohoku","100","Japan-1.png"),("Osaka","200","Japan-2.png"),("Senso-ji","300","Japan-3.png"),("Shibuya","50","Japan-4.png"),("Fuji reflection","90","Japan-5.png"),("Fuji sunrise","20","Japan-6.png"),("Kyoto","80","Japan-7.png"),("Hiroshima","150","Japan-8.png"),("Miyajima","150","Japan-9.png"),("Gozanoishi Shrine","150","Japan-10.png"),("Cold mountains","150","Japan-11.png"),("Warm mountains","150","Japan-12.png");
