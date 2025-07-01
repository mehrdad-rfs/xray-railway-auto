FROM ubuntu:22.04

RUN apt update && apt install -y curl unzip openssl cron supervisor

RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/xray

COPY start.sh /start.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY crontab.txt /etc/cron.d/xray-cron

RUN chmod +x /start.sh && chmod 0644 /etc/cron.d/xray-cron \
    && crontab /etc/cron.d/xray-cron

CMD ["/start.sh"]