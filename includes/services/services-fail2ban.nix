{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.services.fail2ban.enable = lib.mkOption {
		type = lib.types.bool;
		default = true;
	};
	
	config = lib.mkIf config.local.services.fail2ban.enable {

		environment.systemPackages = with pkgs; [
			fail2ban
		];


		#fail2ban-client status
		#fail2ban-client status nginx-url-probe

		environment.etc = {
			# Defines a filter that detects URL probing by reading the Nginx access log
			# test regex with fail2ban-regex -Dv access.log 'REGEX'
			"fail2ban/filter.d/nginx-url-probe.local".text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
				[Definition]
				failregex = ^<HOST> - .* "((GET|POST|HEAD|CONNECT) \/((.*(geoserver|Dr0v|server\.key|kubernetes\.io|view\?panel=config|\?rest_route=|(hostinfo)\.cgi|(laravel)\.log|(application)\.properties|mcp\b|(composer|package|yarn)\.lock|(backup)\.tar\.gz|(nx|rush|vercel|railway)\.json|(wrangler|netlify|fly|config|railway)\.toml|(site|html|public_html|backup)\.zip|(llms|ai|humans|security|secrets|ads|secret)\.txt|(test|config.dev|goods|class-t\.api|sf|kbfr|autoload_classmap|chosen|classwithtostring|api\/mcp|app_dev|as|404|ws|function|an|themes|rip|ioxi-o|inputs|abc|abcd|s1|\/CAE-2\.5|ebkid|177|z70|333|3PJcpMFsD8B|MH|s1|jemo|analate|c|3|5PJcpMFsD8B|bytkl|gjbyv|myglu20|lowfile|sitemap|bnmtp|gfile|huya|go|w|g|class-db|geforce|sm|buy|images|\/aa|wsd|wp|222|simple|sallu|Component|b8|wp_blog_footer|opsh|file|bro|hh|f35|add|configuration|cache|welcome|server-status|phpversion)\.php|metadatauploader|\.docker|config\/config\.js|appsettings\.(Development|Production).json|aws-exports\.js|cms\/|.amplifyrc|\.aws|\.boto|\.claude|\.cursor|\.netrc|\.npmrc|Dockerfile|.s3cfg|credentials(\b|\.ini|.json)|\.sql|(turbo|config|\.config|pnpm-workspace|compose|lerna|serverless|secrets|aws|docker-compose|service-account|key|stats|manifest|docker-compose\.prod|application|application-dev|application-prod|auth|composer|installed|secrets|settings|gcp-sa|sa|_payload|InstallWizard|keyfile)\.(json|php|js|yaml|yml|aspx|jsp)|nv\.js|runtime-config\.js|sendgrid\.env|sentry\.properties|\.within\.website\/x\/cmd\/anubis\/api\/honeypot|actuator\/health)|.*(xmlrpc\.php|wp-json|\/bin\/sh|php:\/\/input|auto_prepend_file|allow_url_include|phpunit|phpinfo|cgi-bin|wp-|admin|info\.php|defaults\.php|boaform|phpmyadmin|(\.|)env(|.txt)|\.git|\.svn|\.bashrc|\.zshrc|\.firebaserc|\.dev.vars|\.htpasswd|\.pypirc|id_rsa(\.pub|)|OpenMarket|viewdefaultdecorator|ad-list-search).*)).*|.*\\x[0-9a-zA-Z]{2}|.*\.\.\/\.\.\/).*"
			'');
		};

		services.fail2ban = {
			enable = true;
			maxretry = 5;
			ignoreIP = [
				"10.0.0.0/8"
				"172.16.0.0/12"
				"192.168.0.0/16"
			];
			bantime = "24h"; # Ban IPs for one day on the first ban
			bantime-increment = {
				enable = true; # Enable increment of bantime after each violation
				formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
				# multipliers = "1 2 4 8 16 32 64";
				maxtime = "168h"; # Do not ban for more than 1 week
				overalljails = true; # Calculate the bantime based on all the violations
			};
		};
	};
}