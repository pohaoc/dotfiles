# dotfiles

Install uv and huggingface and store their cached content outside of boot
```
curl -LsSf https://raw.githubusercontent.com/pohaoc/dotfiles/main/install_tools.sh | bash
```

Resize cloudlab boot partition to use all space
```
curl -LsSf https://raw.githubusercontent.com/<user>/<repo>/<branch>/setup-grow-rootfs.sh | sudo RESIZEROOT=0 bash
```
