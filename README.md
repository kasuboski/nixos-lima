# Run NixOS on a Lima VM
The base config came from [patryk4815/ctftools](https://github.com/patryk4815/ctftools/tree/master/lima-vm)

## Generating the image
On a linux machine or ubuntu lima vm for example:

```bash
# install nix
sh <(curl -L https://nixos.org/nix/install) --daemon
# enable kvm feature
echo "system-features = nixos-test benchmark big-parallel kvm" >> /etc/nix/nix.conf
reboot

# build image
nix --extra-experimental-features nix-command --extra-experimental-features flakes build .#packages.aarch64-linux.box
cp result /tmp/lima/nixos-aarch64.img
```

On your mac:
* Move `nixos-aarch64.img` under `imgs`

## Running NixOS
Edit `user-config.example.nix` and save as `user-config.nix`.
```bash
limactl start --name=default nixos.yaml
limactl copy user-config.nix default:/tmp/

lima
sudo mv /tmp/user-config.nix /etc/nixos/
sudo nixos-rebuild switch
```


