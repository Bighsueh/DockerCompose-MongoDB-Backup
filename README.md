## 讀我
### 目錄
1. 目的
2. 架構
3. 備份方式


### 目的  
透過 cron、mongodump、mongorestore 自動備份目標 mongodb，並透過 docker-compose.yml 實現快速佈署。

---
### 架構  
檔案架構  
```
project_directory/
    ├── docker-compose.yml
    └── backup_mongo/
        ├── backup_script.sh
        ├── cronjob
        └── Dockerfile 
```
docker-compose.yml  
```
version: "3"

services:
  private-mongodb:
    image: mongo:4.4.9
    container_name: private_mongodb_container
    ports:
      - "127.0.0.1:27017:27017"

  public-mongodb:
    image: mongo:4.4.9
    container_name: public_mongodb_container
    ports:
      - "27020:27017"

  backup_mongo:
    build:
      context: ./backup_mongo
    container_name: backup_mongo
    links:
      - private-mongodb:mongo_source
      - public-mongodb:mongo_target

```  
backup_script.sh  
```
#!/bin/bash

# 使用 mongodump 備份資料庫，指定完整路徑
/usr/bin/mongodump --host mongo_source --port 27017 --out /backup

# 恢復備份到目標容器，指定完整路徑
/usr/bin/mongorestore --host mongo_target --port 27017 /backup

```
cronjon  
```
0 */3 * * * root /backup_script.sh
```


Dockerfile  
```
# 使用官方 MongoDB 映像作為基礎映像
FROM mongo:4.4.9

# 安裝 Cron
RUN apt-get update && apt-get -y install cron

# 添加 Cron 作業檔案
COPY cronjob /etc/cron.d/cronjob

# 給予 Cron 作業檔案以及備份腳本可執行權限
RUN chmod +x /etc/cron.d/cronjob
COPY backup_script.sh /backup_script.sh
RUN chmod +x /backup_script.sh

# 啟動 Cron 服務
CMD ["cron", "-f"]

```

---
### 備份方式  
1. 如 ```backup_script.sh``` 所示，會透過 mongodump 將A資料庫備份到資料庫B
```
# 使用 mongodump 備份資料庫，指定完整路徑
/usr/bin/mongodump --host mongo_source --port 27017 --out /backup

# 恢復備份到目標容器，指定完整路徑
/usr/bin/mongorestore --host mongo_target --port 27017 /backup
```
* 若希望單純 dump 出來可以把 ```/usr/bin/mongorestore``` 那行去掉  

2. 使用 cron 表達式， 每三小時執行一次  
cronjob:  
```
0 */3 * * * root /backup_script.sh
```