{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.utilities.hardware.cli.enable = lib.mkOption {
		type = lib.types.bool;
		default = true;
	};
	
	config = lib.mkIf config.local.utilities.hardware.cli.enable {
		environment.systemPackages = with pkgs; [
			usbutils
			pciutils
			lm_sensors
			ethtool
			dmidecode
		];	
	};
}