{ config, lib, pkgs, modulesPath, ... }:
let
	unstable = import <nixos-unstable> { 
		system = "x86_64-linux"; 
		config.allowUnfree = true; 
		config.allowBroken = true; 
	};
in
{
	options.local.network.cli.enable = lib.mkOption {
		type = lib.types.bool;
		default = true;
	};
	
	config = lib.mkIf config.local.network.cli.enable {
		
		programs.mtr.enable = true;
		
		environment.systemPackages = with pkgs; [
			dig
			wget
			curl
			unstable.yt-dlp
			wireguard-tools
			inetutils
			bmon
			slurm-nm
			tcptrack
		];
	};
}