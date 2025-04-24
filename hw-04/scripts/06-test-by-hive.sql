USE test;
SHOW TABLES;
SELECT COUNT(*) FROM titanic_partitioned;
SELECT Sex, COUNT(*) FROM titanic_partitioned WHERE Pclass = '1' GROUP BY Sex;