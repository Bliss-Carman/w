{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.services.httpd."www.prairiefire.ca".enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.services.httpd."www.prairiefire.ca".enable {
		local.services.acme."prairiefire.ca".enable = lib.mkForce true;
		
		services.nginx = {
			virtualHosts."prairiefire.ca" = {
				forceSSL = true;
				useACMEHost = "prairiefire.ca";
				globalRedirect = "www.prairiefire.ca";
			};
			
			virtualHosts."www.prairiefire.ca" = {
				forceSSL = true;
				useACMEHost = "prairiefire.ca";
				
				locations."/" = {
					proxyPass = "http://172.16.100.1:8003";
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

				locations."/wp-admin" = {
					proxyPass = "http://172.16.100.1:8003";
					proxyWebsockets = true; # needed if you need to use WebSocket
					extraConfig = ''
						proxy_ssl_server_name on;
						allow 172.18.0.1; # docker host
						allow 172.16.0.0/12;
						deny all;
					'';
				};

				locations."/xmlrpc.php" = {
					extraConfig = ''
						proxy_ssl_server_name on;
						deny all;
						access_log off;
						log_not_found off;
					'';
				};
				
				
			};
		};
		
	};
}