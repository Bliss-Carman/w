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

				# Add HSTS header with preloading to HTTPS requests.
				# Adding this header to HTTP requests is discouraged
				map $scheme $hsts_header {
					https   "max-age=31536000; includeSubdomains; preload";
				}

				# access_log syslog:server=unix:/dev/log;
				# error_log syslog:server=unix:/dev/log;
			'';


		};

		environment.etc = {
			# Defines a filter that detects URL probing by reading the Nginx access log
			# test regex with fail2ban-regex -Dv access.log 'REGEX'
			"fail2ban/filter.d/nginx-url-probe.local".text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
				[Definition]
				failregex = ^<HOST> - .* "((GET|POST|HEAD|CONNECT) \/((.*(geoserver|Dr0v|server\.key|kubernetes\.io|view\?panel=config|\?rest_route=|(hostinfo)\.cgi|(laravel)\.log|(application)\.properties|mcp\b|(composer|package|yarn)\.lock|(backup)\.tar\.gz|(nx|rush|vercel|railway)\.json|(wrangler|netlify|fly|config|railway)\.toml|(site|html|public_html|backup)\.zip|(llms|ai|humans|security|secrets|ads|secret)\.txt|(test|config.dev|goods|class-t\.api|sf|kbfr|autoload_classmap|chosen|classwithtostring|api\/mcp|app_dev|as|404|ws|function|an|themes|rip|ioxi-o|inputs|abc|abcd|s1|\/CAE-2\.5|ebkid|177|z70|333|3PJcpMFsD8B|MH|s1|jemo|analate|c|3|5PJcpMFsD8B|bytkl|gjbyv|myglu20|lowfile|sitemap|bnmtp|gfile|huya|go|w|g|class-db|geforce|sm|buy|images|\/aa|wsd|wp|222|simple|sallu|Component|b8|wp_blog_footer|opsh|file|bro|hh|f35|add|configuration|cache|welcome|server-status|phpversion)\.php|metadatauploader|\.docker|config\/config\.js|appsettings\.(Development|Production).json|aws-exports\.js|cms\/|.amplifyrc|\.aws|\.boto|\.claude|\.cursor|\.netrc|\.npmrc|Dockerfile|.s3cfg|credentials(\b|\.ini|.json)|\.sql|(turbo|config|\.config|pnpm-workspace|compose|lerna|serverless|secrets|aws|docker-compose|service-account|key|stats|manifest|docker-compose\.prod|application|application-dev|application-prod|auth|composer|installed|secrets|settings|gcp-sa|sa|InstallWizard|keyfile)\.(json|php|js|yaml|yml|aspx|jsp)|nv\.js|runtime-config\.js|sendgrid\.env|sentry\.properties|\.within\.website\/x\/cmd\/anubis\/api\/honeypot|actuator\/health)|.*(xmlrpc\.php|\/bin\/sh|php:\/\/input|auto_prepend_file|allow_url_include|phpunit|phpinfo|cgi-bin|wp-(config|gans|admin|config|login)|admin|info\.php|defaults\.php|boaform|phpmyadmin|(\.|)env(|.txt)|\.git|\.svn|\.bashrc|\.zshrc|\.firebaserc|\.dev.vars|\.htpasswd|\.pypirc|id_rsa(\.pub|)|OpenMarket|viewdefaultdecorator|ad-list-search).*)).*|.*\\x[0-9a-zA-Z]{2}|.*\.\.\/\.\.\/).*"
			'');
		};

		services.fail2ban = {
			jails = {
				nginx-url-probe.settings = { 
					enabled = true;
					filter = "nginx-url-probe";
					logpath = "/var/log/nginx/access.log";
					# action = ''iptables-multiport[name=HTTP, port="http,https"]'';
					backend = "auto"; # Do not forget to specify this if your jail uses a log file
					maxretry = 5; 
					findtime = 600;
					bantime  = 600;
				}; 
			};
		};
		
		networking.firewall.allowedTCPPorts = [ 80 443 ];
	};
}