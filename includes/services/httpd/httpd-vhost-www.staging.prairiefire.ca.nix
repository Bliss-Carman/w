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
					#proxyPass = "http://10.5.5.5:9974";
					#proxyWebsockets = true; # needed if you need to use WebSocket
					#root = "/var/www/blog";
					
					
					return = "200 '<html><body>prairiefire.ca</body></html>'";
					
					extraConfig = ''
						default_type text/html;
						proxy_ssl_server_name on;
					'';
				};
				
				
			};
		};
		
	};
}