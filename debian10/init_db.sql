CREATE USER 'admin'@'localhost' IDENTIFIED BY 'vindex';
CREATE USER 'bmauto'@'localhost' IDENTIFIED BY 'gunicorn';
CREATE DATABASE bmauto;
GRANT ALL ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
GRANT ALL ON bmauto.* TO 'bmauto'@'localhost' WITH GRANT OPTION;