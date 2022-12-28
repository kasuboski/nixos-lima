{ config, modulesPath, pkgs, lib, ... }:

let
    LIMA_CIDATA_MNT = "/mnt/lima-cidata";  # FIXME: hardcoded
    LIMA_CIDATA_DEV = "/dev/disk/by-label/cidata";  # FIXME: hardcoded

    script = ''
    echo "attempting to fetch configuration from LIMA user data..."
    export HOME=/root
    export PATH=${pkgs.lib.makeBinPath [ pkgs.gnused config.nix.package config.system.build.nixos-rebuild]}:$PATH
    export NIX_PATH=nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels

    if [ -f ${LIMA_CIDATA_MNT}/lima.env ]; then
        echo "storage exists";
    else
        echo "storage not exists";
        exit 2
    fi

    cp -f ${./configuration.nix} /etc/nixos/configuration.nix
    cp -f ${./lima-init.nix} /etc/nixos/lima-init.nix
    cp -f ${./lima-runtime.nix} /etc/nixos/lima-runtime.nix
    chmod 664 /etc/nixos/configuration.nix
    chmod 664 /etc/nixos/lima-init.nix
    chmod 664 /etc/nixos/lima-runtime.nix
    sed -i 's@imports = \[];@imports = \[ "/etc/nixos/lima-runtime.nix" ];@g' /etc/nixos/lima-init.nix

    nixos-rebuild switch

    cp "${LIMA_CIDATA_MNT}"/meta-data /run/lima-ssh-ready
    cp "${LIMA_CIDATA_MNT}"/meta-data /run/lima-boot-done
    exit 0
    '';
in {
    imports = [];

    systemd.services.lima-init = {
      inherit script;
      description = "Reconfigure the system from lima-init userdata on startup";

      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      requires = [ "network.target" ];

      restartIfChanged = false;
      unitConfig.X-StopOnRemoval = false;

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };

    fileSystems."${LIMA_CIDATA_MNT}" = {
        device = "${LIMA_CIDATA_DEV}";
        fsType = "auto";
        options = [ "ro" "mode=0700" "dmode=0700" "overriderockperm" "exec" "uid=0" ];
    };
}