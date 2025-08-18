# 🚀 rclone + Google Drive on Ubuntu Setup ☁️

This guide installs **rclone**, configures a **Google Drive** remote, mounts it reliably, and uses it safely from **Docker bind mounts** — avoiding common FUSE/Docker pitfalls. 🐳

---

## ⚡ 1) Install rclone and FUSE

```bash
sudo apt update
sudo apt install -y rclone fuse3
rclone version
```

Enable `allow_other` so non-owner processes (e.g., Docker root) can read the mount:

```bash
echo "user_allow_other" | sudo tee -a /etc/fuse.conf
```

> 💡 If the line already exists, no harm adding again.

---

## 🔑 2) Configure the Google Drive remote (headless-friendly)

Start the interactive config:

```bash
rclone config
```

👉 Recommended answers:
- **n** → new remote → name: `gdrive`
- **storage**: `drive`
- **client_id / client_secret**: press **Enter** (or add your own for higher API limits)
- **scope**: `drive` (full) or `drive.file` (only files created by rclone)
- **headless** flow (server without browser):
  - When it prints a URL, select **y** for remote authorization and run on your laptop:
    ```bash
    rclone authorize "drive"
    ```
  - Paste the long token back into the server prompt ✅

Quick test:

```bash
rclone lsd gdrive:
```

If you see folders, the remote works. 🎉

📂 Config file path: `~/.config/rclone/rclone.conf` (e.g., `/home/ubuntu/.config/rclone/rclone.conf`).

---

## 📂 3) Manual mount (quick smoke test)

Create the mount point and mount with sane defaults (good for Docker):

```bash
mkdir -p /home/ubuntu/gdrive
rclone mount gdrive: /home/ubuntu/gdrive   --allow-other   --uid 1000 --gid 1000 --umask 002   --vfs-cache-mode full   --vfs-cache-max-size 2G   --buffer-size 64M   --dir-cache-time 1h   --poll-interval 1m   --daemon
```

Verify it works ✅:
```bash
mount | grep rclone
ls -la /home/ubuntu/gdrive
touch /home/ubuntu/gdrive/_rclone_test.txt
```

> ⚠️ **Note:** This is a temporary user mount; it won’t persist after reboot. Use **systemd** for reliable auto-mounting.

---
