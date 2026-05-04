#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}=====================================${NC}"
echo -e "${GREEN}   VPS Web Panel Installer v2.0      ${NC}"
echo -e "${CYAN}=====================================${NC}"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
fi

echo -e "${YELLOW}[*] OS: $OS${NC}"

if [[ "$OS" == "centos" || "$OS" == "rhel" || "$OS" == "almalinux" ]]; then
    dnf install -y wget curl python3 git unzip 2>/dev/null
else
    apt update -y 2>/dev/null
    apt install -y wget curl python3 git unzip 2>/dev/null
fi

echo -e "${YELLOW}[*] Installing ttyd...${NC}"
wget -q https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 -O /usr/local/bin/ttyd
chmod +x /usr/local/bin/ttyd
echo -e "${GREEN}[+] ttyd OK${NC}"

echo -e "${YELLOW}[*] Installing FileBrowser...${NC}"
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
filebrowser config init -d /root/filebrowser.db
filebrowser config set -d /root/filebrowser.db --address 0.0.0.0 --port 8080 --root /root
filebrowser users add admin admin123 --perm.admin -d /root/filebrowser.db 2>/dev/null
echo -e "${GREEN}[+] FileBrowser OK${NC}"

echo -e "${YELLOW}[*] Installing Netdata...${NC}"
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --non-interactive --dont-start-it 2>/dev/null
echo -e "${GREEN}[+] Netdata OK${NC}"

IP=$(hostname -I | awk '{print $1}')

mkdir -p /var/www/panel
python3 -c "
ip = '$IP'
html = '''<!DOCTYPE html>
<html>
<head>
<meta charset=\"UTF-8\">
<title>VPS Panel</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:monospace;background:#0d1117;color:#e6edf3;min-height:100vh}
header{background:#161b22;border-bottom:1px solid #30363d;padding:16px 32px;display:flex;align-items:center;gap:12px}
header h1{font-size:20px;color:#58a6ff}
.dot{width:10px;height:10px;background:#3fb950;border-radius:50%;animation:pulse 2s infinite}
@keyframes pulse{0%,100%{opacity:1}50%{opacity:0.4}}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:20px;padding:32px}
.card{background:#161b22;border:1px solid #30363d;border-radius:12px;padding:24px;text-decoration:none;color:inherit;transition:all 0.2s;display:block}
.card:hover{border-color:#58a6ff;transform:translateY(-2px)}
.icon{font-size:40px;margin-bottom:16px}
.card h2{font-size:18px;color:#58a6ff;margin-bottom:8px}
.card p{font-size:13px;color:#8b949e;line-height:1.5}
.port{margin-top:12px;font-size:12px;color:#3fb950;background:#0d1117;padding:4px 10px;border-radius:20px;display:inline-block}
.info{margin:20px 32px 0;background:#161b22;border:1px solid #30363d;border-radius:8px;padding:12px 20px;font-size:13px;color:#8b949e}
.info span{color:#58a6ff}
</style>
</head>
<body>
<header><div class=\"dot\"></div><h1>VPS Web Panel</h1></header>
<div class=\"info\">IP: <span>''' + ip + '''</span> | Status: <span style=\"color:#3fb950\">Online</span></div>
<div class=\"grid\">
<a class=\"card\" href=\"http://''' + ip + ''':7681\" target=\"_blank\"><div class=\"icon\">💻</div><h2>Web Terminal</h2><p>Browser থেকে terminal চালান।</p><span class=\"port\">Port: 7681</span></a>
<a class=\"card\" href=\"http://''' + ip + ''':8080\" target=\"_blank\"><div class=\"icon\">📁</div><h2>File Manager</h2><p>ফাইল upload/download করুন।<br>admin / admin123</p><span class=\"port\">Port: 8080</span></a>
<a class=\"card\" href=\"http://''' + ip + ''':19999\" target=\"_blank\"><div class=\"icon\">📊</div><h2>Monitor</h2><p>CPU, RAM, Disk দেখুন।</p><span class=\"port\">Port: 19999</span></a>
</div></body></html>'''
with open('/var/www/panel/index.html', 'w') as f:
    f.write(html)
print('Dashboard created!')
"

echo -e "${GREEN}[+] Dashboard OK${NC}"

pkill ttyd 2>/dev/null
nohup ttyd -p 7681 -W bash > /var/log/ttyd.log 2>&1 &
echo -e "${GREEN}[+] Terminal: port 7681${NC}"

pkill filebrowser 2>/dev/null
nohup filebrowser -d /root/filebrowser.db > /var/log/filebrowser.log 2>&1 &
echo -e "${GREEN}[+] Files: port 8080${NC}"

systemctl start netdata 2>/dev/null
echo -e "${GREEN}[+] Monitor: port 19999${NC}"

pkill -f "python3 -m http" 2>/dev/null
cd /var/www/panel && nohup python3 -m http.server 9090 > /var/log/panel.log 2>&1 &
echo -e "${GREEN}[+] Dashboard: port 9090${NC}"

echo ""
echo -e "${CYAN}=============================${NC}"
echo -e "${GREEN} Done! Open in browser:     ${NC}"
echo -e "${CYAN}=============================${NC}"
echo -e "${GREEN} http://$IP:9090 ${NC}"
echo -e "${GREEN} http://$IP:7681 ${NC}"
echo -e "${GREEN} http://$IP:8080 ${NC}"
echo -e "${GREEN} http://$IP:19999 ${NC}"
