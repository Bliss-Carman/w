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
				set_real_ip_from 10.0.0.0/8;
				set_real_ip_from 172.16.0.0/12;
				real_ip_header X-Forwarded-For;
				real_ip_recursive on;

				access_log syslog:server=unix:/dev/log;
				error_log syslog:server=unix:/dev/log;
			'';


		};
		
		networking.firewall.allowedTCPPorts = [ 80 443 ];
	};
}