{ config, lib, pkgs, modulesPath, ... }:

{
	imports = [
		../hardware/hardware-qemu-guest.nix
		
		../network/network-cli.nix
		../network/network-browsers-cli.nix
		
		../services/services-acme.nix
		../services/services-reverse-proxy.nix
		../services/services-wireguard-server.nix
		../services/wireguard/wireguard-secrets.nix
		../services/services-sshd.nix

		../services/acme/acme-staging.prairiefire.ca.nix
		../services/acme/acme-prairiefire.ca.nix
		
		../services/httpd/httpd-vhost-www.staging.prairiefire.ca.nix
		../services/httpd/httpd-vhost-phpmyadmin.staging.prairiefire.ca.nix
		
		../stacks/stack-staging.prairiefire.ca/stack-staging.prairiefire.ca.nix
		../stacks/stack-rustdesk-server/stack-rustdesk-server.nix

		../system/system-nixos-agenix.nix
		../system/system-nixos.nix
		../system/system-overcommit-memory.nix
		../system/system-runtimes-docker.nix
		
		../utilities/utilities-file-extractors.nix
		../utilities/utilities-file-maintenance.nix
		../utilities/utilities-hardware-cli.nix
		../utilities/utilities-processes.nix
		
		../../users/usersandgroups.nix
	];
	
	# Locale
	time.timeZone = "America/Winnipeg";
	i18n.defaultLocale = "en_CA.UTF-8";
	
	security.pam.loginLimits = [
		{
			domain = "*";
			type = "soft";
			item = "nofile";
			value = "8192";
		}
	];
	
	# Expected Packages
	environment.systemPackages = with pkgs; [
		util-linux
		git
	];
	
}
