wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt update
curl -sL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nginx certbot python3-certbot-nginx nodejs build-essential mongodb-org graphicsmagick
sudo npm install -g inherits n
sudo n 20.6.1

sudo certbot --nginx -d rocketchat.steven.net
sudo certbot renew --dry-run
sudo vim /etc/nginx/nginx.conf
sudo vim /etc/nginx/sites-available/rocketchat.steven.net
sudo ln -s /etc/nginx/sites-available/rocketchat.heyvaldemar.net /etc/nginx/sites-enabled/
sudo unlink /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl status nginx

curl -L https://releases.rocket.chat/latest/download -o /tmp/rocket.chat.tgz
tar -xzf /tmp/rocket.chat.tgz -C /tmp
rm -f /tmp/rocket.chat.tgz
cd /tmp/bundle/programs/server
npm install
sudo mv /tmp/bundle /opt/Rocket.Chat
sudo useradd -M rocketchat
sudo usermod -L rocketchat
sudo chown -R rocketchat:rocketchat /opt/Rocket.Chat
sudo vim /lib/systemd/system/rocketchat.service
sudo sed -i "s/^# engine:/ engine: mmapv1/" /etc/mongod.conf
sudo sed -i "s/^#replication:/replication:\n replSetName: rs01/" /etc/mongod.conf
sudo systemctl enable mongod
sudo systemctl start mongod
sudo systemctl status mongod
mongo --eval "printjson(rs.initiate())"
sudo systemctl enable rocketchat
sudo systemctl start rocketchat
sudo systemctl status rocketchat