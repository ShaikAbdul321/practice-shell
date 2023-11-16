source common.sh
component=nginx

echo -e "$color Installing ${component} Server$nocolor"
yum install ${component} -y &>>${logfile}
status_check $?
echo -e "$color Removing default content$nocolor"
cd /usr/share/${component}/html
rm -rf * &>>${logfile}
status_check $?
echo -e "$color Downloading new content to ${component} server$nocolor"
curl -O https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>${logfile}
unzip frontend.zip &>>${logfile}
rm -rf frontend.zip
status_check $?
echo -e "$color Configuring reverse proxy ${component} server$nocolor"
cp /root/practice-shell/roboshop.conf /etc/${component}/default.d/roboshop.conf
status_check $?
echo -e "$color enabling and starting ${component} server$nocolor"
systemctl enable ${component} &>>${logfile}
systemctl restart ${component}
status_check $?