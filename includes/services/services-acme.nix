{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.services.acme.enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.services.acme.enable {
		security.acme.acceptTerms = true;
	};
}

