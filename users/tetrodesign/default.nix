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
				"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1Tw0jM+mVeZ1GrU4wAMuF0O5CT3iJjecBMZ5L31pZpR7xYccZwxag9+JBK0ykMST6oh3pdisM1KA6u6pgP1TYXcaCKp7jJORgQAPY5GSMhDdr3pztssmJn3j3l1fsoJDhrjCLwk608qMASfpFYHB/GF82RQyXs1HkkWbqth45c5sdAQkI1T94SFjxuUAJKP1UGJc/3fiLmksZ+LemXsFH59P1EVOQ2qU20D2GyPi25GK+NT0mtw0nsJPG7X2dI1sjelfIiZd4XN+62+85e37I3u3QalTJjZrViLhahm39mDJ0WJBi/AuTojZ1hJxmjDUkfHdK+Y4flaQpBqqCLqNViG2sdts3PNYUCwnaSTsqV/YmYuQuuAJ56Cncdbh8VVgOqNTzDmink9cP+sUuW7m1OQHmr1NHquuXVkNpijjDEjA9yzTRDtRJR+H9dcMSJrY1BNdDW/Iv5m9ZYIqiarlYBB55EKjEwVRvi3wsBV1h+mWg8TMjaOuTvIDv/n1AHJOQXfLArR2J13lQRZZjxV/E66GX/EsDOeCmXPuD224impqs0p2JLef2RyXUFW8fCIKBKOAxTV+Xz0rBtsempj35r1xK+fTbwMeYw316LJhfcL0lxz7PXVlXTZdFjo86cWmIDs7SDGxsZSTOjfOIkCCizTCXE3/+P6wDXAzIUcFp1Q== nicole@tetrodesign.com"
			];
		};
	};
	
	
}
