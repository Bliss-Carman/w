
{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.hardware.qemu.guest.enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.hardware.qemu.guest.enable {
		services.qemuGuest.enable = true;
	};
}
