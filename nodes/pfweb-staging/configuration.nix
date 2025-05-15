{ config, pkgs, ... }:

{
	imports = [
		./hardware-configuration.nix
		../../includes/base/base-cli.nix
	];

	# Bootloader.
	boot.loader.grub.enable = true;
	boot.loader.grub.device = "/dev/vda";
	boot.loader.grub.useOSProber = true;

	local.hardware.qemu.guest.enable = true;
	local.services.reverse-proxy.enable = true;
	local.services.httpd."www.staging.prairiefire.ca".enable = true;
	local.system.runtimes.docker.enable = true;
	local.services.reverse-proxy.enable = true;

	# May have to be disabled in bootstrap.
	local.services.wireguard-server.enable = true; 

	networking.hostName = "pfweb"; # Define your hostname.

	environment.systemPackages = with pkgs; [

	];
	
	system.stateVersion = "24.11";
}
