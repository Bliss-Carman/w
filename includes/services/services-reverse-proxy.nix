{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.services.reverse-proxy.enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.services.reverse-proxy.enable {
		local.services.acme."staging.prairiefire.ca".enable = lib.mkForce true;
		local.services.acme."prairiefire.ca".enable = lib.mkForce true;
		local.services.acme.enable = true;
		
		services.nginx = {
			enable = true;
			recommendedProxySettings = true;
			recommendedTlsSettings = true;
			recommendedGzipSettings = true;
			recommendedOptimisation = true;
			clientMaxBodySize = "2G";
			
			# A default site so that it doesn't give the alphabetically first site for unknown hostnames.
			virtualHosts."_" = {
				forceSSL = true;
				useACMEHost = "staging.prairiefire.ca";
				
				default = true;
				locations."/" = {
					
					return = "200 '<html><body></body></html>'";
					extraConfig = ''
						default_type text/html;
					'';
				};
			};
			
			commonHttpConfig = ''
				
			'';


		};
		
		networking.firewall.allowedTCPPorts = [ 80 443 ];
	};
}