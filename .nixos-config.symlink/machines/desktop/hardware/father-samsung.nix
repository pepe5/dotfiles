{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../father.nix
  ];

  nix.maxJobs = 3;
  nix.buildCores = 3;

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "usb_storage" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.kernel.sysctl."vm.swappiness" = 5; # Use swap more reluctantly.

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/da4295f4-1ccb-4933-b123-a72bf24cc371";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5552313a-e149-4b79-a833-c17b5e3dc03d";
    fsType = "ext4";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/26e21201-3c99-4dca-876b-fb6de48d5aa2";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/var/home";
    fsType = "none";
    options = [ "bind" ];
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/874a388b-a8d0-4143-af41-473b7e30bd45"; } ];
}
