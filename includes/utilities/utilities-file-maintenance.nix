{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.utilities.file.maintenance.enable = lib.mkOption {
		type = lib.types.bool;
		default = true;
	};
	
	config = lib.mkIf config.local.utilities.file.maintenance.enable {
		environment.systemPackages = with pkgs; [
			par2cmdline-turbo
			ncdu
		];	
	};
}