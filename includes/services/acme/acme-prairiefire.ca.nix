{ config, lib, pkgs, modulesPath, ... }:
{
	imports = [
		./acme-secrets.nix
	];
	
	options.local.services.acme."prairiefire.ca".enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.services.acme."prairiefire.ca".enable {
		
		security.acme.certs."prairiefire.ca" = {
			domain = "prairiefire.ca";
			extraDomainNames = [ "*.prairiefire.ca" ];
			group = config.services.nginx.group;
			
			# The LEGO DNS provider name. Depending on the provider, need different
			# contents in the credentialsFile below.
			dnsProvider = "linode";
			dnsPropagationCheck = true;
			credentialsFile = config.age.secrets."dns-linode.age".path;

			reloadServices = [
				"nginx"
			];
		};
		
		# systemctl status acme-prairiefire.ca.service
		# journalctl -u  acme-prairiefire.ca.service --since today --follow
	};
}