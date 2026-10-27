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


		#fail2ban-client status --all
		#fail2ban-client status nginx-url-probe

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