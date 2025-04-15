# Inception of Things (IoT)

## Project Summary
This project introduces infrastructure as code (IaC) concepts by setting up and configuring:
- Virtualization with Vagrant
- Container orchestration with K3s/K3d
- GitOps practices with ArgoCD
- CI/CD workflows

## How to Run Each Part

### Part 1: Vagrant + K3s Setup
```
cd p1
vagrant up
```

### Part 2: K3s + 3 Apps + Ingress
```
cd p2
# Instructions to run part 2
```

### Part 3: K3d + ArgoCD + GitHub CI/CD
```
cd p3
# Instructions to run part 3
```

### Bonus: GitLab Integration (Optional)
```
cd bonus
# Instructions to run bonus part
```

**Important Note**: All commands must be executed in the VM terminal.

vagrant plugin list
# should show: vagrant-parallels

prlctl --version
# should output something like: prlctl version 18.x.x

vagrant up --provider=parallels
# should now create a VM instead of showing the error

# 📦 1. Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


# 🛠️ 2. Install Vagrant
brew tap hashicorp/tap
brew install hashicorp/tap/hashicorp-vagrant

# 🔌 3. Install the Parallels provider plugin for Vagrant
vagrant plugin install vagrant-parallels

# 🔍 4. Check everything is working
vagrant --version
# ✅ Should output something like: Vagrant 2.4.x

vagrant plugin list
# ✅ Should list: vagrant-parallels

prlctl --version
# ✅ Should output the Parallels CLI version (e.g., 18.x.x)

# 🚀 5. Go to the project folder and boot the VMs
cd ~/inception_of_things/p1
vagrant up --provider=parallels

# 📁 Optional: If Parallels is not detected by Vagrant
# Sometimes Parallels CLI needs to be explicitly enabled. Run:
sudo xcode-select --install      # (if not installed yet)
sudo spctl --master-disable      # (to allow apps from anywhere)

# install plugin
vagrant plugin install vagrant-parallels
----------

# Destroy everything
vagrant destroy -f

# List all running VMs with CLI
prlctl list --all

# Check the status of each VM once they're up
vagrant ssh acoezardS -c "sudo kubectl get nodes"

# To manually run provisioning
vagrant provision

# To connect to either VM directly
vagrant ssh acoezardS
vagrant ssh acoezardSW

# Add box
vagrant box add roboxes/ubuntu2204 --provider=parallels

# incide vm
sudo apt install -y virtualbox vagrant
