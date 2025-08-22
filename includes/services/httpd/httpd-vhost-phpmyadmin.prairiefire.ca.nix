{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.services.httpd."phpmyadmin.prairiefire.ca".enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.services.httpd."phpmyadmin.prairiefire.ca".enable {
		local.services.acme."prairiefire.ca".enable = lib.mkForce true;
		
		services.nginx = {
			
			virtualHosts."phpmyadmin.prairiefire.ca" = {
				forceSSL = true;
				useACMEHost = "prairiefire.ca";
				
				locations."/" = {
					proxyPass = "http://172.16.100.1:8005";
					proxyWebsockets = true; # needed if you need to use WebSocket
					
					extraConfig = ''
						proxy_ssl_server_name on;
						allow 172.18.0.1;
						allow 172.16.0.0/12;
						deny all;
					'';
				};
				
				
			};
		};
		
	};
}