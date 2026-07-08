# dotfiles

Install uv and huggingface and store their cached content outside of boot
```
curl -LsSf https://raw.githubusercontent.com/pohaoc/dotfiles/main/install_tools.sh | bash
```
Install docker (with post-installation) and cache outside of boot
```
curl -fsSL -o install_docker.sh https://raw.githubusercontent.com/pohaoc/dotfiles/main/install_docker.sh
chmod +x install_docker.sh
sudo ./install_docker.sh
```
Resize cloudlab boot partition to use all space
```
curl -LsSf https://raw.githubusercontent.com/<user>/<repo>/<branch>/setup-grow-rootfs.sh | sudo RESIZEROOT=0 bash
```
