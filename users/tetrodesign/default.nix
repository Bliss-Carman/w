{ config, lib, pkgs, modulesPath, ... }:
let 
	username = "tetrodesign";
	fullName = "tetrodesign";
in
{
	options.local.users.tetrodesign.enable = lib.mkOption {
		type = lib.types.bool;
		default = true;
	};
	
	config = lib.mkIf config.local.users.tetrodesign.enable {
		age.secrets."userHashedPasswordFile-${username}".file = ../../secrets/userHashedPasswordFile-${username}.age;
		
		users.users."${username}" = {
			uid=1002;
			isNormalUser = true;
			description = fullName;
			hashedPasswordFile = config.age.secrets."userHashedPasswordFile-${username}".path;
			createHome = true;
			extraGroups = [
				"networkmanager"
				"libvirtd"
				"users"
			];
			packages = with pkgs; [
			];
            openssh.authorizedKeys.keys = [
			];
		};
	};
	
	
}
