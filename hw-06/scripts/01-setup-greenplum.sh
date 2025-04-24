#!/bin/bash

DATA_DIR="/home/user/team-20-data"
CSV_FILE="titanic.csv"
GP_PORT="8081"
GP_DB="idp"

if [[ ! -f "$DATA_DIR/$CSV_FILE" ]]; then
  exit 1
fi

gpfdist -d "$DATA_DIR" -p "$GP_PORT" > /dev/null 2>&1 &
sleep 2

cat <<EOF | psql -d "$GP_DB"

DROP EXTERNAL TABLE IF EXISTS team20;
CREATE EXTERNAL TABLE team20 (
  PassengerId INT,
  Survived INT,
  Pclass INT,
  Name TEXT,
  Sex TEXT,
  Age FLOAT,
  SibSp INT,
  Parch INT,
  Ticket TEXT,
  Fare FLOAT,
  Cabin TEXT,
  Embarked TEXT
)
LOCATION ('gpfdist://localhost:${GP_PORT}/${CSV_FILE}')
FORMAT 'CSV' (HEADER);

DROP TABLE IF EXISTS inteam20;
CREATE TABLE inteam20 (
  PassengerId INT,
  Survived INT,
  Pclass INT,
  Name TEXT,
  Sex TEXT,
  Age FLOAT,
  SibSp INT,
  Parch INT,
  Ticket TEXT,
  Fare FLOAT,
  Cabin TEXT,
  Embarked TEXT
);

INSERT INTO inteam20 SELECT * FROM team20;

SELECT * FROM inteam20 LIMIT 10;

EOF
