{ config, lib, pkgs, ... }:

{
	imports = [
		./hardware-configuration.nix
		../../includes/base/base-cli.nix
	];

	# Bootloader.
	boot.loader.grub.enable = true;
	boot.loader.grub.device = "nodev";
	boot.loader.timeout = 10;

	boot.kernelParams = ["console=ttyS0,19200n8"];
	boot.loader.grub.extraConfig = ''
		serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
		terminal_input serial;
		terminal_output serial;
	'';

	local.hardware.qemu.guest.enable = true;
	local.services.reverse-proxy.enable = true;

	local.system.runtimes.docker.enable = true;
	# local.services.rustdesk-server.enable = true;
	local.stacks."rustdesk-server".enable = true;
	local.stacks."staging.prairiefire.ca".enable = true;

	local.services.httpd."www.staging.prairiefire.ca".enable = true;
	local.services.httpd."phpmyadmin.staging.prairiefire.ca".enable = true;

	# May have to be disabled in bootstrap.
	local.services.wireguard-server.enable = true; 

	networking.hostName = "pfweb-linode-toronto"; # Define your hostname.

	environment.systemPackages = with pkgs; [

	];

	networking.nameservers = [ "1.1.1.1" "9.9.9.9" "8.8.8.8" "8.8.4.4" ];
	networking.usePredictableInterfaceNames = false;
	networking.useDHCP = false;
	networking.interfaces.eth0.useDHCP = true;

	# environment.systemPackages = with pkgs; [
	# 	inetutils
	# 	mtr
	# 	sysstat
	# ];

	system.stateVersion = "25.05";
}
