color="\e[33m"
nocolor="\e[0m"
logfile="/tmp/roboshop.log"
app_path="/app"

useradd()
{
  id roboshop &>>${logfile}
    if [ $? -eq 0 ];then
      useradd roboshop &>>${logfile}
    fi
}

status_check()
{
   if [ $? -eq 0 ];then
      echo Success
    else
      echo failure
    fi
}

nodejs()
{
  echo -e "$color Downloading Nodejs repo file$nocolor"
  curl -sL https://rpm.nodesource.com/setup_19.x | sudo -E bash -  bash &>>$logfile
  status_check
  echo -e "$color Installing Nodejs server$nocolor"
  yum install nodejs -y &>>$logfile
  status_check
  app_start
  npm install &>>$logfile
  status_check
  service_start
}

service_start()
{
  echo -e "$color Creating ${component} Service file$nocolor"
  cp /root/practice-shell/${component}.service /etc/systemd/system/${component}.service
  status_check
  echo -e "$color system reload,enabling and starting ${component} service$nocolor"
  systemctl daemon-reload
  status_check
  systemctl enable ${component} &>>${logfile}
  systemctl restart ${component}
  status_check
}

app_start()
{
  echo -e "$color Adding user and location$nocolor"
  useradd
  status_check
  rm -rf ${app_path} &>>$logfile
  status_check
  mkdir ${app_path} &>>$logfile
  status_check
  cd ${app_path}
  echo -e "$color Downloading new app content and dependencies to ${component} server$nocolor"
  curl -O https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>$logfile
  status_check
  unzip ${component}.zip &>>$logfile
  status_check
  rm -rf ${component}.zip
}

mongo_schema()
{
echo -e "$color DOWNLOADING AND INSTALLING THE MONGODB SCHEMA$nocolor"
cp /root/practice-shell/mongodb.repo /etc/yum.repos.d/mongodb.repo
status_check
echo -e "$color Installing Mongo schema$nocolor"
yum install mongodb-org-shell -y &>>${logfile}
status_check
echo -e "$color Loading schema$nocolor"
mongo --host mongodb-dev.shaik.website <${app_path}/schema/${component}.js &>>${logfile}
status_check
}

maven()
{
  echo -e "$color Installing maven server$nocolor"
  yum install maven -y &>>${logfile}
  status_check
  app_start
  echo -e "$color Downloading dependencies and builiding application to ${component} server$nocolor"
  mvn clean package &>>${logfile}
  status_check
  mv target/${component}-1.0.jar ${component}.jar &>>${logfile}
  status_check
  mysql_schema
  service_start
}

mysql_schema()
{
  echo -e "$color Downloading and installing the mysql schema$nocolor"
  yum install mysql -y &>>${logfile}
  status_check
  mysql -h mysql-dev.shaik.website -uroot -pRoboShop@1 < ${app_path}/schema/${component}.sql &>>${logfile}
  status_check
}

python()
{
  echo -e "$color Installing python server$nocolor"
  yum install python36 gcc python3-devel -y &>>${logfile}
  status_check
  app_start
  echo -e "$color Downloading dependencies for python server$nocolor"
  pip3.6 install -r requirements.txt &>>${logfile}
  status_check
  service_start
}

golang()
{
  echo -e "$color Installing golang server$nocolor"
  yum install golang -y &>>${logfile}
  status_check
  app_start
  echo -e "$color Downloading dependencies for golang server$nocolor"
  go mod init dispatch &>>${logfile}
  go get &>>${logfile}
  go build &>>${logfile}
  status_check
  service_start
}
