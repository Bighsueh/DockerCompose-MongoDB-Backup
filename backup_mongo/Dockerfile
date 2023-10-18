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
