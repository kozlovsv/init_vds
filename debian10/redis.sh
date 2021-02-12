apt install redis-server -y
sed -i 's/supervised no/supervised systemd/g' /etc/redis/redis.conf
systemctl restart redis