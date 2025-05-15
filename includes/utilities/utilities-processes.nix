{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.utilities.processes.enable = lib.mkOption {
		type = lib.types.bool;
		default = true;
	};
	
	config = lib.mkIf config.local.utilities.processes.enable {
		environment.systemPackages = with pkgs; [
			procps
			htop
			psmisc
		];
	};
}