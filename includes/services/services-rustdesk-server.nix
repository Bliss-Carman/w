{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.services.rustdesk-server.enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.services.reverse-proxy.enable {
		
		services.rustdesk-server.enable = true;
		services.rustdesk-server.openFirewall = true;
		
	};
}