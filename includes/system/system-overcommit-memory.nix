{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.system.overcommit-memory = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.system.overcommit-memory {
		boot.kernel.sysctl = {
			"vm.overcommit_memory" = "1";
		};
	};
}