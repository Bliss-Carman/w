{ config, lib, pkgs, modulesPath, ... }:
{
	config = lib.mkIf (
		config.local.services.acme."staging.prairiefire.ca".enable
	) {
		age.secrets."dns-linode.age".file = ../../../secrets/dns-linode.age;
	};
	
	
	
}