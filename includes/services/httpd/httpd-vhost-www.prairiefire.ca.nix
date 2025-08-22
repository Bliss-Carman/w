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
				
				locations."/robots.txt" = {
					extraConfig = ''
						add_header Content-Type text/plain;
						return 200 "User-agent: AI2Bot\nUser-agent: Ai2Bot-Dolma\nUser-agent: aiHitBot\nUser-agent: Amazonbot\nUser-agent: Andibot\nUser-agent: anthropic-ai\nUser-agent: Applebot\nUser-agent: Applebot-Extended\nUser-agent: bedrockbot\nUser-agent: Brightbot 1.0\nUser-agent: Bytespider\nUser-agent: ChatGPT-User\nUser-agent: Claude-SearchBot\nUser-agent: Claude-User\nUser-agent: Claude-Web\nUser-agent: ClaudeBot\nUser-agent: cohere-ai\nUser-agent: cohere-training-data-crawler\nUser-agent: Cotoyogi\nUser-agent: Crawlspace\nUser-agent: Diffbot\nUser-agent: DuckAssistBot\nUser-agent: EchoboxBot\nUser-agent: FacebookBot\nUser-agent: facebookexternalhit\nUser-agent: Factset_spyderbot\nUser-agent: FirecrawlAgent\nUser-agent: FriendlyCrawler\nUser-agent: Google-CloudVertexBot\nUser-agent: Google-Extended\nUser-agent: GoogleOther\nUser-agent: GoogleOther-Image\nUser-agent: GoogleOther-Video\nUser-agent: GPTBot\nUser-agent: iaskspider/2.0\nUser-agent: ICC-Crawler\nUser-agent: ImagesiftBot\nUser-agent: img2dataset\nUser-agent: ISSCyberRiskCrawler\nUser-agent: Kangaroo Bot\nUser-agent: meta-externalagent\nUser-agent: Meta-ExternalAgent\nUser-agent: meta-externalfetcher\nUser-agent: Meta-ExternalFetcher\nUser-agent: MistralAI-User/1.0\nUser-agent: MyCentralAIScraperBot\nUser-agent: NovaAct\nUser-agent: OAI-SearchBot\nUser-agent: omgili\nUser-agent: omgilibot\nUser-agent: Operator\nUser-agent: PanguBot\nUser-agent: Panscient\nUser-agent: panscient.com\nUser-agent: Perplexity-User\nUser-agent: PerplexityBot\nUser-agent: PetalBot\nUser-agent: PhindBot\nUser-agent: Poseidon Research Crawler\nUser-agent: QualifiedBot\nUser-agent: QuillBot\nUser-agent: quillbot.com\nUser-agent: SBIntuitionsBot\nUser-agent: Scrapy\nUser-agent: SemrushBot\nUser-agent: SemrushBot-BA\nUser-agent: SemrushBot-CT\nUser-agent: SemrushBot-OCOB\nUser-agent: SemrushBot-SI\nUser-agent: SemrushBot-SWA\nUser-agent: Sidetrade indexer bot\nUser-agent: TikTokSpider\nUser-agent: Timpibot\nUser-agent: VelenPublicWebCrawler\nUser-agent: Webzio-Extended\nUser-agent: wpbot\nUser-agent: YandexAdditional\nUser-agent: YandexAdditionalBot\nUser-agent: YouBot\nDisallow: /\n\n";
					'';
				};

				locations."/" = {
					proxyPass = "http://172.16.100.1:8003";
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

						add_header Strict-Transport-Security $hsts_header;

						# Minimize information leaked to other domains
						add_header 'Referrer-Policy' 'origin-when-cross-origin';

						# Disable embedding as a frame
						add_header X-Frame-Options DENY;

						# Prevent injection of code in other mime types (XSS Attacks)
						add_header X-Content-Type-Options nosniff;
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
						return 444;
					'';
				};
				
				
				
			};
		};
		
	};
}