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

						if ($http_user_agent ~* "AI2Bot|Ai2Bot-Dolma|aiHitBot|Amazonbot|Andibot|anthropic-ai|Applebot|Applebot-Extended|bedrockbot|Brightbot 1.0|Bytespider|ChatGPT-User|Claude-SearchBot|Claude-User|Claude-Web|ClaudeBot|cohere-ai|cohere-training-data-crawler|Cotoyogi|Crawlspace|Diffbot|DuckAssistBot|EchoboxBot|FacebookBot|facebookexternalhit|Factset_spyderbot|FirecrawlAgent|FriendlyCrawler|Google-CloudVertexBot|Google-Extended|GoogleOther|GoogleOther-Image|GoogleOther-Video|GPTBot|iaskspider/2.0|ICC-Crawler|ImagesiftBot|img2dataset|ISSCyberRiskCrawler|Kangaroo Bot|meta-externalagent|Meta-ExternalAgent|meta-externalfetcher|Meta-ExternalFetcher|MistralAI-User/1.0|MyCentralAIScraperBot|NovaAct|OAI-SearchBot|omgili|omgilibot|Operator|PanguBot|Panscient|panscient.com|Perplexity-User|PerplexityBot|PetalBot|PhindBot|Poseidon Research Crawler|QualifiedBot|QuillBot|quillbot.com|SBIntuitionsBot|Scrapy|SemrushBot|SemrushBot-BA|SemrushBot-CT|SemrushBot-OCOB|SemrushBot-SI|SemrushBot-SWA|Sidetrade indexer bot|TikTokSpider|Timpibot|VelenPublicWebCrawler|Webzio-Extended|wpbot|YandexAdditional|YandexAdditionalBot|YouBot") { 
							return 444;
						}

						if ($arg_sjsl) {
							access_log off;
							#log_not_found off;
							return 444;
						}
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