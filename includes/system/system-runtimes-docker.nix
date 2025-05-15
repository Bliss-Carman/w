{ config, lib, pkgs, modulesPath, ... }:

{
	options.local.system.runtimes.docker.enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.system.runtimes.docker.enable {
		virtualisation.docker.enable = true;
		virtualisation.docker.package = pkgs.docker_25;
		virtualisation.docker.liveRestore = false;
	};
}
