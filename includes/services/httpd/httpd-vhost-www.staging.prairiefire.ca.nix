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
						set_real_ip_from 10.0.0.0/8;
						set_real_ip_from 172.16.0.0/12;
						real_ip_header X-Forwarded-For;
						real_ip_recursive on;
						#proxy_set_header Host $host;
						proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
						proxy_set_header X-Forwarded-Proto $scheme;
						proxy_set_header X-Forwarded-Host $http_host;
						proxy_set_header X-Forwarded-URI $request_uri;
						proxy_set_header X-Forwarded-Ssl on;
						proxy_set_header X-Forwarded-For $remote_addr;
						proxy_set_header X-Real-IP $remote_addr;
						proxy_ssl_server_name on;
					'';
				};
				
				
			};
		};
		
	};
}