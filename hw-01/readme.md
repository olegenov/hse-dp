# HW-01

узел для входа 176.109.91.22

```
team-20
jn 192.168.1.82
nn 192.168.1.83
dn-00 192.168.1.84
dn-01 192.168.1.85
```

Развертывание кластера hdfs, включающего в себя 3 DataNode и обязательные для функционирования кластера сервисы: NameNode, Secondary NameNode.

## Подготовка

### Ключи ssh
> Выполнить на jn:
```
01-ssh-setup.sh
```

**Подробнее:**

Создаем ключ ssh на jn
```
ssh-keygen
```

Добавляем в список авторизованных
```
cat .ssh/id_ed<>.pub >> .ssh/authorized_keys
```
Распространяем ключ по узлам
```
scp .ssh/authorized_keys <id-узла>:/home/team/.ssh/authorized_keys
```

### Обращение к узлам по имени
> Выполнить на всех узлах:
```
02-edit-hosts.sh
```

**Подробнее:**

На всех узлах DN редактируем ```/etc/hosts/``` по примеру:

```
127.0.1.1 team-20-jn # Название узла

# Остальные узлы кроме текущего, включая nn
<ip узла> <название узла>
```

На узле NN редактируем ```/etc/hosts/```:
```
192.168.1.83 team-20-nn

# Остальные узлы кроме текущего
<ip узла> <название узла>
```

### Создание пользователя hadoop
> Выполнить на всех узлах:
```
03-add-hadoop-user.sh
```

**Подробнее:**

На всех узлах выполняем:

```
sudo adduser hadoop
```

### Скачивание hadoop
> Выполнить на всех узлах:
```
04-install-hadoop.sh
05-set-profile.sh
```
>Скопировать профиль по узлам:
```
scp /home/hadoop/.profile <имя-узла>:/home/hadoop/
```

**Подробнее:**

На всех узлах (или на одном с последующим копированием архива и распаковкой) выполняем:
```
sudo -i -u hadoop
wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
tar -xzvf hadoop-3.4.0.tar.gz
```

На узле nn:
В .profile добавляем:
```
export HADOOP_HOME=/home/hadoop/hadoop-3.4.0
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
```
Распространяем по другим узлам:
```
scp .profile <имя узла>:/home/hadoop
```

Теперь можно проверить доступность hadoop на всех узлах командой:
```
hadoop version
```

## Настройка конфигурации

> Выполнить на nn, от имени hadoop:
```
06-config-hadoop.sh
```

**Подробнее:**

### Скрипт для переменных окружения

В ```~/hadoop-3.4.0/etc/hadoop/hadoop-env.sh``` добавляем:
```
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

### Настройка кор-конфига
В ```~/hadoop-3.4.0/etc/hadoop/core-site.xml``` изменяем:
```
<configuration>
<property>
  <name>fs.defaultFS</name>
  <value>hdfs://team-20-nn:9000</value>
</property>
</configuration>
```

### Настройка конфига файловой системы
В ```~/hadoop-3.4.0/etc/hadoop/hdfs-site.xml``` изменяем:
```
<configuration>
<property>
  <name>dfs.replication</name>
  <value>3</value>
</property>
</configuration>
```

### Дополнение списка воркеров
```~/hadoop-3.4.0/etc/hadoop/workers``` изменяем:
```
#localhost
team-20-nn // названия узлов
team-20-dn-00
team-20-dn-01
```

### Распространение изменений по другим узлам:
```
scp hadoop-env.sh <название-узла>:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp core-site.xml <название-узла>:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp hdfs-site.xml <название-узла>:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp workers <название-узла>:/home/hadoop/hadoop-3.4.0/etc/hadoop
```

## Запуск сервисов

> Выполнить на nn, от имени hadoop:
```
07-format-start-hdfs.sh
```

**Подробнее:**

### Форматирование файловой системы
В nn-узле с пользователя hadoop выполняем в директории ```hadoop-3.4.0```:
```
bin/hdfs namenode -format
```

### Запуск кластера
```
sbin/start-dfs.sh
```

После успешного запуска команда
```
jps
```
Отображает:
```
12048 DataNode
12902 Jps
12265 SecondaryNameNode
11883 NameNode
```
А на dn-серверах:
```
34290 DataNode
34474 Jps
```

## Проверка
Листинг корневой директории ничего не выводит:
```
hdfs dfs -ls /
```

Создаем файл и проверяем наличие:
```
$ hdfs dfs -mkdir /test
$ hdfs dfs -ls /

Found 1 items
drwxr-xr-x   - hadoop supergroup          0 2025-04-22 23:23 /test

$ hdfs dfs -touch /test/test.txt
$ hdfs dfs -ls /test/

Found 1 items
-rw-r--r--   3 hadoop supergroup          0 2025-04-22 23:26 /test/test.txt
```

В логах видим:
```
2025-04-22 23:26:51,634 INFO org.apache.hadoop.hdfs.server.namenode.FSEditLog: Number of transactions: 3 Total time for transactions(ms): 13 Number of transactions batched in Syncs: 0 Number of syncs: 3 SyncTimes(ms): 8 
2025-04-22 23:26:51,688 INFO org.apache.hadoop.hdfs.StateChange: DIR* completeFile: /test/test.txt is closed by DFSClient_NONMAPREDUCE_-2052014539_1
```
