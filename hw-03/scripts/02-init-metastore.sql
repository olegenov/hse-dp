CREATE DATABASE metastore;
CREATE USER hive with password 'hiveUltraPass';
GRANT ALL PRIVILEGES ON DATABASE "metastore" to hive;
ALTER DATABASE metastore OWNER TO hive;