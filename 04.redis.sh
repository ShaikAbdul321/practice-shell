color="\e[33m"
noclor="$nocolor"
logfile="/tmp/roboshop.log"

echo -e "$color Downloading Redis repo$nocolor"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>${logfile}
echo -e "$color Enabling Redis-6.2 from package$nocolor"
Yum module list &>>${logfile}
yum module enable redis:remi-6.2 -y &>>${logfile}
echo -e "$color Installing Redis$nocolor"
yum install redis -y &>>${logfile}
echo -e "$color Changing the listen address$nocolor"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf
echo -e "$color Enabling and starting Redis server$nocolor"
systemctl enable redis &>>${logfile}
systemctl restart redis
