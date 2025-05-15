{ config, pkgs, ... }:

{
	imports = [
		./hardware-configuration.nix
		../../includes/base/base-cli.nix
	];

	# Bootloader.
	boot.loader.grub.enable = true;
	boot.loader.grub.device = "/dev/vda";
	boot.loader.grub.useOSProber = true;

	networking.hostName = "pfweb"; # Define your hostname.

	# Enable networking
	#networking.networkmanager.enable = true;

	# Set your time zone.
	time.timeZone = "America/Winnipeg";

	# Select internationalisation properties.
	i18n.defaultLocale = "en_CA.UTF-8";

	# Configure keymap in X11
	services.xserver.xkb = {
		layout = "us";
		variant = "";
	};

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.dan = {
		isNormalUser = true;
		description = "Dan Saul";
		extraGroups = [ "networkmanager" "wheel" ];
		packages = with pkgs; [];
	};

	# Allow unfree packages
	nixpkgs.config.allowUnfree = true;

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [

	];
	# Enable the OpenSSH daemon.
	services.openssh = {
		enable = true;
		settings.PermitRootLogin = "yes";
	};

	local.services.reverse-proxy.enable = true;
    local.services.wireguard-server.enable = true;



	system.stateVersion = "24.11";
}
