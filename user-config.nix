{ config, modulesPath, pkgs, lib, ... }:
{
    imports = [
        (fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master")
    ];

    services.vscode-server.enable = true;
    # still requires systemctl --user enable auto-fix-vscode-server.service
    # systemctl --user start auto-fix-vscode-server.service
    environment.systemPackages = with pkgs; [
        htop
        lsd
    ];
}