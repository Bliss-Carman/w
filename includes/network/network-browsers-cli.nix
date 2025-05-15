{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.network.browsers.cli.enable = lib.mkOption {
		type = lib.types.bool;
		default = true;
	};
	
	config = lib.mkIf config.local.network.browsers.cli.enable {
		environment.systemPackages = with pkgs; [
			elinks
		];
	};
}