{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.services.rustdesk-server.enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.services.rustdesk-server.enable {
		
		services.rustdesk-server = {
			enable = true;
			openFirewall = true;
			signal.relayHosts = [
				"www.staging.prairiefire.ca"
			];
		};
	};
}