{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.backup.secrets.enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};

	config = lib.mkIf config.local.backup.secrets.enable {
		age.secrets."backup-encrypted-recipients.age".file = ./backup-encrypted-recipients.age;
	};
	
}