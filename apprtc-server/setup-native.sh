DEBIAN_FRONTEND=noninteractive apt-get update -y &&     apt-get install -y     build-essential     apt-transport-https ca-certificates curl software-properties-common     supervisor
adduser --disabled-password --gecos "" deploy
su deploy -c     "bash \"install -m700 -d /home/deploy/.ssh\""
sudo su deploy
fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile
swapon /swapfile
swapon --show
cp /etc/fstab /etc/fstab.bak
echo "/swapfile none swap sw 0 0" >> /etc/fstab
sysctl vm.swappiness=10
sysctl vm.vfs_cache_pressure=50
echo "vm.swappiness=10\nvm.vfs_cache_pressure = 50" >> /etc/sysctl.conf
swapon --show
echo "LC_ALL=en_US.UTF-8" >> /etc/environment
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen en_US.UTF-8
update-locale
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
DEBIAN_FRONTEND=noninteractive apt-get update -y && apt-get install docker-ce -y
usermod -aG docker ubuntu
sudo -H -u deploy bash -c "curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash"
sudo -H -u deploy bash -c ". ~/.nvm/nvm.sh; nvm install --lts; npm install -g gulp-cli"
export GAE_VER=1.9.74
export GOLANG_VER=1.8.3
export GOLANG_TAR=go$GOLANG_VER.linux-amd64.tar.gz
wget https://storage.googleapis.com/golang/$GOLANG_TAR
tar -C /usr/local -xzf $GOLANG_TAR
export PATH=$PATH:/usr/local/go/bin
export GOPATH=/goWorkspace
mkdir -p $GOPATH/src

export LIBEVENT_VER=2.1.8
export COTURN_VER=4.5.0.7
export PUBLIC_IP=127.0.0.1

wget https://github.com/libevent/libevent/releases/download/release-$LIBEVENT_VER-stable/libevent-$LIBEVENT_VER-stable.tar.gz
tar xvfz libevent-$LIBEVENT_VER-stable.tar.gz
cd libevent-$LIBEVENT_VER-stable
./configure && make && make install

cd /home/ubuntu/
wget http://turnserver.open-sys.org/downloads/v$COTURN_VER/turnserver-$COTURN_VER.tar.gz
tar xvfz turnserver-$COTURN_VER.tar.gz
cd turnserver-$COTURN_VER
./configure && make && make install
turnadmin -a -u ninefingers -r apprtc -p youhavetoberealistic

vim /etc/turnserver.conf

cd /home/ubuntu/
git clone https://github.com/aimakun/apprtc.git
cd apprtc
git checkout dev-appscale
ln -s /home/ubuntu/apprtc/src/collider/collider $GOPATH/src
ln -s /home/ubuntu/apprtc/src/collider/collidermain $GOPATH/src
ln -s /home/ubuntu/apprtc/src/collider/collidertest $GOPATH/src

go get collidermain
go install collidermain

# Use WebRTC-Docker for supervisord config & ice.js
cd /home/ubuntu/
git clone https://github.com/aimakun/WebRTC-Docker.git
cd WebRTC-Docker/apprtc-server/
git checkout dev-appscale
sudo -H -u deploy bash -c ". ~/.nvm/nvm.sh; nvm install 8; nvm use 8; cd /home/ubuntu/WebRTC-Docker/apprtc-server/ && npm install express cors"
mkdir /webrtc_avconf && chmod 777 /webrtc_avconf
cp turnserver.conf /etc/turnserver.conf
cp ice.js /ice.js
supervisord -c /home/ubuntu/WebRTC-Docker/apprtc-server/apprtc_supervisord.conf

# TODO: nginx server blocks point to SSL termination endpoints (ICE/WebSocket/Room App proxy port with same backend)
# /etc/nginx/site-enabled/proxy.conf OR
# /etc/nginx/site-enabled/aliases.conf

# Open ports: 80,443 (AppScale proxy), 3034,8090

# Certbot
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot python-certbot-nginx

# sudo certbot certonly --nginx
# sudo certbot renew --dry-run
# sudo certbot renew --pre-hook "service nginx stop" --post-hook "yes | cp -f /etc/letsencrypt/live/server0.app.liszo.com/fullchain.pem /etc/nginx/mycert.pem; yes | cp -f /etc/letsencrypt/live/server0.app.liszo.com/privkey.pem /etc/nginx/mykey.pem; service nginx start;"
