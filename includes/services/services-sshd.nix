{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.services.sshd.enable = lib.mkOption {
		type = lib.types.bool;
		default = true;
	};
	
	config = lib.mkIf config.local.services.sshd.enable {
		services.openssh = {
			enable = true;
			settings.PasswordAuthentication = false;
			settings.KbdInteractiveAuthentication = false;
			settings.PermitRootLogin = "yes";
		};
		programs.ssh.startAgent = true;
	};
}