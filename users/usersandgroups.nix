
{ config, lib, pkgs, modulesPath, ... }:

{
	imports =
	[
		./dan/default.nix
		./lindsey/default.nix
        ./tetrodesign/default.nix
		./root/default.nix
	];
	
	# Groups
	users.groups.media = {
		gid=990;
	};

	# Users
	users.mutableUsers = false;
	
	# Icons
	fileSystems."/var/lib/AccountsService/icons" = {
		device = "/etc/usericons.d";
		options = [ "bind" ];
	};
}
