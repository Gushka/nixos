{ config, lib, pkgs, modulesPath, ... }:

let
  hostname = "raspberrypi";

  nixos-hardware = "${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz"}/raspberry-pi/4";

in {
  imports =
    [ 
      nixos-hardware
      (modulesPath + "/installer/scan/not-detected.nix")
    ];
  
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    kernelParams = ["cma=256M"];
    
    # https://github.com/NixOS/nixos-hardware/issues/631#issuecomment-1584100732
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
      "pcie_brcmstb" # required for the pcie bus to work
      "reset-raspberrypi" # required for vl805 firmware to load
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };
  
  hardware = {
    enableRedistributableFirmware = true;
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
      options = ["noatime"];
    };

  swapDevices = [ ];

  environment.systemPackages = with pkgs; 
  [
    libraspberrypi
    raspberrypi-eeprom
  ];

  networking.useDHCP = lib.mkDefault true;
  
  networking.hostName = hostname;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
