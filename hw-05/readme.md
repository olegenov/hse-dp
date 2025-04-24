# HW-05

узел для входа 176.109.91.22

```
team-20
jn 192.168.1.82
nn 192.168.1.83
dn-00 192.168.1.84
dn-01 192.168.1.85
```

В рамках потока (prefect) или ОАГ (Airflow) реализовать процесс обработки данных, состоящий из следующих шагов:
1. Запустить сессию Apache Spark под управлением YARN в рамках кластера, развернутого в предыдущих заданиях
2. Подключиться к кластеру HDFS, развернутому в предыдущих заданиях
3. Используя Spark прочитать данные, которые были предварительно загружены на HDFS
4. Выполнить несколько трансформаций данных (например, агрегацию или преобразование типов)
5. Сохранить данные как таблицу


>team@team-20-jn:
```sh
01-run.sh
```

**Подробнее:**

## Подготовка

### Удаление старой партиции
team@team-20-jn:
```sh
beeline --verbose=true -u jdbc:hive2://team-20-jn:5433 -n scott -p tiger
```
```sql
DROP TABLE test.titanic_partitioned
```

### Установка prefect
team@team-20-jn (venv):
```sh
pip install prefect
```

## Создание скрипта
Создаем файл ```flow.py``` c  кодом  ```scripts/flow.py```

Запускаем
```
python flow.py
```

Видим результат
```
22:25:55.181 | INFO    | Task run 'stop_spark-f09' - Finished in state Completed()
22:25:55.211 | INFO    | Flow run 'ivory-degu' - Finished in state Completed()
22:25:55.219 | INFO    | prefect - Stopping temporary server on http://127.0.0.1:8451
(venv) hadoop@team-20-jn:~$ hdfs dfs -ls /user/hive/warehouse/test.db
Found 3 items
drwxr-xr-x   - hadoop supergroup          0 2025-04-23 23:23 /user/hive/warehouse/test.db/people
drwxr-xr-x   - hadoop supergroup          0 2025-04-24 20:20 /user/hive/warehouse/test.db/spark_partitions
drwxr-xr-x   - hadoop supergroup          0 2025-04-24 22:25 /user/hive/warehouse/test.db/titanic_partitioned
```