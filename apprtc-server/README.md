# How to use
First, change hostname and Let's Encrypt contact email to your own by:
```
sed -i 's/server1.example.com/your.hostname.com/g' .docker/proxy/custom_hosts.conf
sed -i 's/server1.example.com #/your.hostname.com/g' docker-compose.yml
sed -i 's/me@example.com #/youremail@somewhere.com/g' docker-compose.yml
```
Then ready for deploy with:  `docker-compose up -d`

# Endpoint
- https://your.hostname.com >> 8080
- https://your.hostname.com:3034 >> 3033 (ICE Server)
- wss://your.hostname.com:8090 >> 8089 (websocket)
- STUN / TURN server still be the same
