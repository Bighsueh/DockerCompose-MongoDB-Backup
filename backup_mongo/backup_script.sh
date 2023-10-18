#!/bin/bash

# 使用 mongodump 備份資料庫，指定完整路徑
/usr/bin/mongodump --host mongo_source --port 27017 --out /backup

# 恢復備份到目標容器，指定完整路徑
/usr/bin/mongorestore --host mongo_target --port 27017 /backup
