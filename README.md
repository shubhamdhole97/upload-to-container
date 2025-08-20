
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



# 🚀 rclone + Google Drive on Ubuntu Setup ☁️






## 🔑 1) Configure the Google Drive remote (headless-friendly)

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


