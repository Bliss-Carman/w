{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.services.httpd."phpmyadmin.staging.prairiefire.ca".enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.services.httpd."phpmyadmin.staging.prairiefire.ca".enable {
		local.services.acme."staging.prairiefire.ca".enable = lib.mkForce true;
		
		services.nginx = {
			
			virtualHosts."phpmyadmin.staging.prairiefire.ca" = {
				forceSSL = true;
				useACMEHost = "staging.prairiefire.ca";
				
				locations."/" = {
					proxyPass = "http://172.16.100.1:8002";
					proxyWebsockets = true; # needed if you need to use WebSocket
					
					extraConfig = ''
						proxy_ssl_server_name on;
					'';
				};
				
				locations."/robots.txt" = {
					extraConfig = ''
						add_header Content-Type text/plain;
						return 200 "User-agent: *\nDisallow: /\n";
					'';
				};
			};
		};
		
	};
}