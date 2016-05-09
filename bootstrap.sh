#!/usr/bin/env bash


apt-get update
apt-get install -y apache2


#if ! [ -L /var/www ]; then
#  rm -rf /var/www
#  ln -fs /vagrant /var/www
#fi

echo "Now installing java"
apt-get -y -q install software-properties-common htop
add-apt-repository ppa:webupd8team/java
apt-get -y -q update
#echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
#apt-get -y -q install oracle-java8-installer
apt-get -y -q install oracle-java7-installer
update-java-alternatives -s java-7-oracle

echo "Now installing requirements for Lace"
apt-get -y -q install zip unzip libmysqlclient-dev python-pip python-dev sqlite3
pip install Flask
pip install Flask-SQLAlchemy
pip install Flask-Markdown
pip install MySQL-python
pip install Flask-HTTPAuth
#sudo apt-get install libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk
sudo apt-get -y -q install python-imaging 
sudo apt-get -y -q install python-lxml 

#git clone git@github.com:brobertson/Lace.git

echo  "Now getting Lace"
wget https://github.com/brobertson/Lace/archive/secretlace.zip
unzip secretlace.zip
rm secretlace.zip
mv Lace* Lace
chown -R vagrant:vagrant Lace-secretlace/
cd Lace

echo "now set actual settings for Lace"
#cp example_local_settings.py local_settings.py
echo "database_uri = 'sqlite:////home/vagrant/Lace/lace_sqlite.db'" > local_settings.py
echo 'exist_db_uri = "http://localhost:8080/exist/"' >> local_settings.py
#generate a random key for the digest authentication
#currently not using digest authentication, but we'll keep this here for when we do
#echo http_auth_secret_key = \"`date +%s | sha256sum | base64 | head -c 12`\" >> local_settings.py 
python import_to_lace_from_tar.py samples/*
cd -

echo "Now getting misc"
apt-get -y -q install lynx-cur

echo "now getting eXist-db"
wget https://bintray.com/artifact/download/existdb/releases/eXist-db-setup-2.2.jar
sudo apt-get -y -q install expect 

echo "now run an expect script to install eXist-db"
/usr/bin/expect <<- 'EOD'

set timeout 200
spawn /usr/bin/java -jar eXist-db-setup-2.2.jar -console

expect "vagrant]"
send "/home/vagrant/eXist-db\n"
expect "redisplay"
send "1\n"
expect "ebapp/WEB-INF/data]"
send "\n"
expect "redisplay"
send "1\n"
expect "]"
send "foo\n"
expect "foo]"
send "foo\n"
expect "1024]"
send "\n"
expect "128]"
send "\n"
expect "redisplay"
send "1\n"
expect eof 

EOD

echo "now make eXist a service on boot"
/home/vagrant/eXist-db/tools/wrapper/bin/exist.sh install
/home/vagrant/eXist-db/tools/wrapper/bin/exist.sh start
sleep 10

echo "now make apache2 connection"
apt-get -y -q install libapache2-mod-wsgi
cd /home/vagrant/Lace
echo "now correct the address of the Lace directory" 
sudo sed -i.bak 's/\/home\/brucerob\/SecretLace\/Lace/\/home\/vagrant\/Lace/' lace.wsgi
rm lace.wsgi.bak
echo "now set up the Apache WSGI service"
cp /vagrant/Apache/000-default.conf /etc/apache2/sites-available/
echo "reload apache2"
sudo service apache2 reload

echo "make eXist user 'laceuser'"
apt-get -y -q install ant
ant -f /home/vagrant/Lace/eXist-db/ant/adduser.xml -Dpath=/home/vagrant/eXist-db -Dlogin=laceUser -Dsecret=laceUser -Duser.group=laceUser -Droot.login=admin -Droot.password=foo -Dexist.uri=localhost:8080 addUser
echo "put the xquery application files in eXist"
/home/vagrant/eXist-db/bin/client.sh -u admin -P foo -s -c /db/ -p /home/vagrant/Lace/eXist-db/db/
echo "modify permissions of applications"
cd /home/vagrant/Lace/eXist-db/db/apps/laceApp
#echo 'declare namespace xmldb = "http://exist-db.org/xquery/xmldb";' > /home/vagrant/try.xq
for file in `ls .` 
do 
ant -f /home/vagrant/Lace/eXist-db/ant/adduser.xml -Droot.login=admin -Droot.password=foo -Dpath=/home/vagrant/eXist-db -Dupdate.file=$file
done

echo "now set the server for javascript"
cd /home/vagrant/Lace
echo 'var exist_server_address = "http://localhost:8899";' > /home/vagrant/Lace/static/javascripts/lace_config.js

echo "now preprocess all the hocr files in database"
cd /home/vagrant/eXist-db
bin/client.sh -s -u admin -P foo -x -F /home/vagrant/Lace/eXist-db/db/apps/laceApp/addManuallyVerifiedAttr.xq

echo "now modifying ~/.bash_profile"
echo "export EXIST_HOME='/home/vagrant/eXist-db'" >> /home/vagrant/.bash_profile
echo "export LACE_HOME='/home/vagrant/Lace'" >> /home/vagrant/.bash_profile
#echo "now keeping env. variable EXIST_HOME when using sudo"
#echo 'Defaults env_keep += "EXIST_HOME"' >> /etc/sudoers
