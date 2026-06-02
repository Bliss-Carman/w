{ config, lib, pkgs, modulesPath, ... }:
let 
	username = "lindsey";
	fullName = "Lindsey Childs";
in
{
	options.local.users.lindsey.enable = lib.mkOption {
		type = lib.types.bool;
		default = true;
	};
	
	config = lib.mkIf config.local.users.lindsey.enable {
		age.secrets."userHashedPasswordFile-${username}".file = ../../secrets/userHashedPasswordFile-${username}.age;
		
		users.users."${username}" = {
			uid=1001;
			isNormalUser = true;
			description = fullName;
			hashedPasswordFile = config.age.secrets."userHashedPasswordFile-${username}".path;
			createHome = true;
			extraGroups = [
				"networkmanager"
				"wheel"
				"docker"
				"libvirtd"
				"media"
				"users"
				"adbusers"
				"kvm"
			];
			packages = with pkgs; [
			];
			openssh.authorizedKeys.keys = [
				"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEX9irGef8dhKeboc/4ry2P3nliXz0wLjKMP9FANAfb3" # Lindsey Home Office
				"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGIrTM1WkfHJ8DQdSqhn/e+fhAUNfUn8d9rtPhwG3cfj lindsey@Lindseys-Mac-mini.local" # Lindsey Office
			];
		};
	};
	
	
}
