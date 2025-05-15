
{ config, lib, pkgs, modulesPath, ... }:
let 
	username = "root";
in
{
	age.secrets."userHashedPasswordFile-${username}".file = ../../secrets/userHashedPasswordFile-${username}.age;
	
	users.users."${username}" = {
		hashedPasswordFile = config.age.secrets."userHashedPasswordFile-${username}".path;
		
		openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4DXCWnspO5WUrirR33EAGTIl692+COgeds0Tvtw6Yd" # dan
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEX9irGef8dhKeboc/4ry2P3nliXz0wLjKMP9FANAfb3" # Lindsey Home Office
				"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDmlKthJNoPPW9F8yYZGj9rtQI1mqf26ddF2qU6shD1Kho/5/1x+3B3Z1mwyGXQfLyeB+E3bx7lLh+OTXIyUYxTOj4zxOylCt2HXcOZlGA2FjM8Cx4iGwrNa7wVhPyZGbmLd7n4IQvf9iSqNcGAuD3jyeXsqbcExs3PLGnhyFPH7ptk1EnviGDZ89FV2XA4P01G/beI/t4NmwTcSHfl3WPxKFKuWeCED6InHLKMnhJkqDb2AzF0cSp3IZweS9YEvOI+YBFtvAeZAP0ls5wCxtHjE1p9bZcPgWt+7o9mV2uAOMzdK5c0RljYySEUcpX4NQBOglQVeD3gUCecTHHIkDMkJpXdIcfp2IuPn1vup44R9yR8+J73rTzype+DKx64sRbOG9s6GL1/lPUsaojDthS2fPCFtjeDQY1uJeaZvhscBYkktwQXp9Qrpnqq2GVR26uV7Jp/9EzynNeizXz3DkrLhS7h4D9qlrX4OHPUUckoV8bbqYNTXnkrTNcvdGAJZY0= prairiefire@Lindseys-iMac.local" # Lindsey Office
		];
		
		#openssh.authorizedKeys.keys = [
		#] ++ config.users.users.dan.openssh.authorizedKeys.keys;
	};
}
