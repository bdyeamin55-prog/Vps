# 🖥️ VPS Web Panel

Browser থেকে আপনার VPS সম্পূর্ণ control করুন!

---

## ✨ Features

| Feature | Description |
|---|---|
| 💻 Web Terminal | Browser থেকে terminal চালান |
| 📁 File Manager | ফাইল upload/download/delete করুন |
| 📊 System Monitor | CPU, RAM, Disk real-time দেখুন |
| 🌐 Dashboard | সব কিছু এক জায়গায় |

---

## 🚀 Install করুন (১ কমান্ডে)

```bash
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install.sh && bash install.sh
```

> ⚠️ `YOUR_USERNAME` এবং `YOUR_REPO` আপনার GitHub username ও repo নাম দিয়ে বদলান।

---

## 🌐 Install হলে যা পাবেন

```
🌐 Dashboard     →  http://YOUR_IP:9090
💻 Terminal      →  http://YOUR_IP:7681
📁 File Manager  →  http://YOUR_IP:8080
📊 Monitor       →  http://YOUR_IP:19999
```

**File Manager Login:**
- Username: `admin`
- Password: `admin123`

---

## ▶️ Panel চালু করুন

```bash
bash install.sh
```

## ⏹️ Panel বন্ধ করুন

```bash
pkill ttyd
pkill filebrowser
systemctl stop netdata
pkill -f "python3 -m http"
echo "✅ সব বন্ধ হয়ে গেছে!"
```

## 🔄 Panel রিস্টার্ট করুন

```bash
pkill ttyd filebrowser 2>/dev/null
pkill -f "python3 -m http" 2>/dev/null
nohup ttyd -p 7681 -W bash > /var/log/ttyd.log 2>&1 &
nohup filebrowser -d /root/filebrowser.db > /var/log/filebrowser.log 2>&1 &
systemctl restart netdata
cd /var/www/panel && nohup python3 -m http.server 9090 > /var/log/panel.log 2>&1 &
echo "✅ Panel রিস্টার্ট হয়েছে!"
```

---

## 🖥️ Supported OS

- ✅ CentOS Stream 8/9
- ✅ RHEL 8/9
- ✅ AlmaLinux
- ✅ Ubuntu 20.04 / 22.04
- ✅ Debian 10 / 11 / 12

---

## ⚠️ Note

- Root অথবা sudo access লাগবে
- Port `7681`, `8080`, `9090`, `19999` open রাখুন
- File Manager default password পরিবর্তন করুন!

---

## 📄 License

MIT License — Free to use!# Vps
