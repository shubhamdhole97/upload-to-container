
# Terraform AWS EC2 with Docker, Rclone, and Crontab

This project provisions an **AWS EC2 instance** using **Terraform** with a remote backend stored in an **S3 bucket**.  
The instance is automatically configured with **Docker**, **Rclone (with FUSE3)**, and **Crontab**.

---

## 🚀 Features

- **Infrastructure as Code (IaC):** Manage AWS resources via Terraform.
- **Remote State Management:** Terraform backend configured with Amazon S3 for safe state storage.
- **Automated Provisioning:** EC2 instance bootstrapped with Docker, Rclone, FUSE3, and Crontab.
- **Ready for Containers:** Docker installed and ready to run applications.
- **Cloud Sync:** Rclone with FUSE3 for Google Drive or other cloud storage mounts.
- **Task Scheduling:** Crontab installed for automated job scheduling.





---

## ⚙️ Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed
- AWS CLI configured with proper IAM permissions
- S3 bucket created for Terraform backend

---

## 🛠️ Usage

### 1️⃣ Clone Repository
```bash
git clone https://github.com/your-username/aws-terraform-docker-rclone.git
cd aws-terraform-docker-rclone
```

### 2️⃣ Initialize Terraform
```bash
terraform init
```

### 3️⃣ Plan Deployment
```bash
terraform plan
```

### 4️⃣ Apply Deployment
```bash
terraform apply -auto-approve
```

---

## 🔑 Terraform Backend Configuration (S3)

The backend ensures **state consistency** and **team collaboration**.

```hcl
terraform {
  backend "s3" {
    bucket         = "your-tf-state-bucket"
    key            = "envs/prod/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "tf-state-locking"
  }
}
```

- **bucket** → S3 bucket name to store state file  
- **key** → Path inside bucket (unique per environment)  
- **region** → AWS region of the bucket  
- **dynamodb_table** → Provides state locking to avoid race conditions  

---

## 🐳 Installed Tools

- **Docker** → Run and manage containers
- **Rclone + FUSE3** → Sync and mount Google Drive / cloud storage
- **Crontab** → Schedule automated jobs

---

## 📌 Example: Verify Installation

```bash
docker --version
rclone version
crontab -l
```

---



# rclone + Google Drive on Ubuntu (Docker‑friendly, systemd mount)

Got you. Here’s a clean, battle‑tested setup to install **rclone** on Ubuntu, configure **Google Drive**, mount it reliably with **systemd**, and use it from **Docker bind mounts**—without the common FUSE/Docker gotchas.

---

## 1) Install rclone (Ubuntu)

```bash
sudo apt update
sudo apt install -y rclone fuse3
rclone version
```

Enable `allow_other` for FUSE so processes (like Docker root) can access the mount:

```bash
echo "user_allow_other" | sudo tee -a /etc/fuse.conf
```

---

## 2) Configure a Google Drive remote (headless‑friendly)

Run the interactive config:

```bash
rclone config
```

**Prompts (recommended):**

- `n` → new remote → name: `gdrive`
- `storage`: `drive`
- `client_id` / `client_secret`: *(optional; press Enter, or add your own for higher API limits)*
- `scope`: `drive` *(full)* or `drive.file` *(only files created by rclone)*

**Headless login (no browser on server):** When it says to open a URL, choose **y** for remote authorization and run on your laptop:

```bash
rclone authorize "drive"
```

Copy the long token back to the server prompt.

**Test:**

```bash
rclone lsd gdrive:
```

If you see folders, you’re good. *(The config lives at e.g. `/home/ubuntu/.config/rclone/rclone.conf`. We’ll point systemd at this path.)*

---

## 3) Create a mount point and test a manual mount

```bash
mkdir -p /home/ubuntu/gdrive

# Good general flags for Docker access + performance/stability
rclone mount gdrive: /home/ubuntu/gdrive   --allow-other   --uid 1000 --gid 1000 --umask 002   --vfs-cache-mode full   --vfs-cache-max-size 2G   --buffer-size 64M   --dir-cache-time 1h   --poll-interval 1m   --daemon
```

**Quick checks:**

```bash
mount | grep rclone
ls -la /home/ubuntu/gdrive
touch /home/ubuntu/gdrive/_rclone_test.txt
```

If `rclone lsd gdrive:` works but the mount doesn’t, ensure `/etc/fuse.conf` has `user_allow_other`, then retry the mount command.

---

## 4) Make the mount persistent (systemd service)

Create a system‑wide service so Docker (root) can read it:

```bash
sudo tee /etc/systemd/system/rclone-gdrive.service >/dev/null <<'EOF'
[Unit]
Description=Rclone Mount for Google Drive
Wants=network-online.target
After=network-online.target

[Service]
Type=notify
# IMPORTANT: use the *user* config path for rclone.conf:
Environment=RCLONE_CONFIG=/home/ubuntu/.config/rclone/rclone.conf
User=ubuntu
Group=ubuntu
ExecStart=/usr/bin/rclone mount gdrive: /home/ubuntu/gdrive   --allow-other   --uid 1000 --gid 1000 --umask 002   --vfs-cache-mode full   --vfs-cache-max-size 2G   --buffer-size 64M   --dir-cache-time 1h   --poll-interval 1m
ExecStop=/bin/fusermount3 -uz /home/ubuntu/gdrive
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

**Notes**

- Do **not** include `--daemon` under systemd.
- If your username isn’t `ubuntu`, adjust `User`, `Group`, and the config path.

**Enable + start:**

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now rclone-gdrive
systemctl status rclone-gdrive
```

---

## 5) Use from Docker (bind mount)

Once mounted at `/home/ubuntu/gdrive`, you can bind it into containers:

```bash
docker run --rm -it   -v /home/ubuntu/gdrive:/data   alpine:latest ls -la /data
```

> Tip: Keep your compose/services dependent on the mount being ready (e.g., via `restart: unless-stopped` and appropriate healthchecks) if they need the GDrive content at startup.

---

## Troubleshooting

- **Permission denied / empty mount in Docker:** Ensure `/etc/fuse.conf` contains `user_allow_other` and you used `--allow-other` in the mount.
- **Service flaps on boot:** Check `journalctl -u rclone-gdrive -e` for errors (bad `RCLONE_CONFIG` path, missing creds, etc.).
- **Mount disappears after network flap:** systemd restarts on failure (`Restart=on-failure`). If needed, increase `RestartSec` or add `RequiresMountsFor=` to dependent services.

---

**Done!** Your Google Drive is now mounted at `/home/ubuntu/gdrive` and ready for Docker bind mounts.
```


