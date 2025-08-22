{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.services.httpd."www.staging.prairiefire.ca".enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.services.httpd."www.staging.prairiefire.ca".enable {
		local.services.acme."staging.prairiefire.ca".enable = lib.mkForce true;
		
		services.nginx = {
			virtualHosts."staging.prairiefire.ca" = {
				forceSSL = true;
				useACMEHost = "staging.prairiefire.ca";
				globalRedirect = "www.staging.prairiefire.ca";
			};
			
			virtualHosts."www.staging.prairiefire.ca" = {
				forceSSL = true;
				useACMEHost = "staging.prairiefire.ca";
				
				locations."/" = {
					proxyPass = "http://172.16.100.1:8000";
					proxyWebsockets = true; # needed if you need to use WebSocket
					
					extraConfig = ''
						proxy_ssl_server_name on;

						if ($arg_sjsl) {
							access_log off;
							#log_not_found off;
							return 403;
						}
					'';
				};
				
				
			};
		};
		
	};
}