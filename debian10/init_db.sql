CREATE USER 'admin'@'localhost' IDENTIFIED BY 'vindex';
CREATE USER 'tendercrm'@'localhost' IDENTIFIED BY 'gunicorn';
CREATE DATABASE tendercrm;
GRANT ALL ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
GRANT ALL ON tendercrm.* TO 'tendercrm'@'localhost' WITH GRANT OPTION;