{ config, lib, pkgs, modulesPath, ... }:

{
	imports = [
		# Nixos
		# nix-channel --add "https://nixos.org/channels/nixos-unstable" "nixos-unstable"
		# nix-channel --add https://github.com/ryantm/agenix/archive/main.tar.gz agenix
		# nix-channel --update
		./system-nixos-agenix.nix
	];
	
	# Allow unfree packages
	nixpkgs.config.allowUnfree = true;

	nix.gc = {
		automatic = true;
		dates = "weekly";
		options = "--delete-older-than 30d";
	};

	nix.settings.auto-optimise-store = true; 
	
	system.copySystemConfiguration = true;
	
	environment.systemPackages = with pkgs; [
		nix-index
	];
	
	nix.settings.experimental-features = [
		"nix-command"
		"flakes"
	];
}
