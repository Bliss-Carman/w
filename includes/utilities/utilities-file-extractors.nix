{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.utilities.file.extractors.enable = lib.mkOption {
		type = lib.types.bool;
		default = true;
	};
	
	config = lib.mkIf config.local.utilities.file.extractors.enable {
		environment.systemPackages = with pkgs; [
			unzip
			rar
			p7zip
		];	
	};
}