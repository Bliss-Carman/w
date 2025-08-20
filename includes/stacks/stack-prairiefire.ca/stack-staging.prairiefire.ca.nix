{ config, lib, pkgs, modulesPath, ... }:
let
	packageName = "stack-staging.prairiefire.ca";
	UID = "0";
	GID = "0";
	stacksDataRoot = "/stacks";
in
{
	options.local.stacks."staging.prairiefire.ca".enable = lib.mkOption {
		type = lib.types.bool;
		default = true;
	};
	
	config = lib.mkIf config.local.stacks."staging.prairiefire.ca".enable {
		local.services.httpd."www.staging.prairiefire.ca".enable = lib.mkForce true;
		
		age.secrets."prairiefire.ca-env.age".file = ../../secrets/prairiefire.ca-env.age;
		age.secrets."mysql-root-password.age".file = ../../secrets/mysql-root-password.age;
		
		environment.etc."stacks/${packageName}/compose.yaml".text = (
			builtins.replaceStrings [
					''''${packageName}''
					''''${stacksDataRoot}''
					''''${MYSQL_ROOT_PASSWORD_FILE}''
				] 
				[
					packageName
					stacksDataRoot
					config.age.secrets."mysql-root-password.age".path
				] 
				(builtins.readFile ./compose.yml)
			)
		;
		
		
		
		systemd.services."${packageName}" = {
			wantedBy = ["multi-user.target"];
			after = ["docker.service" "docker.socket"];
			path = [pkgs.docker];
			script = ''
				docker compose --env-file ${config.age.secrets."prairiefire.ca-env.age".path} -f /etc/stacks/${packageName}/compose.yaml up --remove-orphans
			'';
			restartTriggers = [
				config.environment.etc."stacks/${packageName}/compose.yaml".source
			];
		};
		
		system.activationScripts.makeDavisDirs = lib.stringAfter [ "var" ] ''
			mkdir -p ${stacksDataRoot}/${packageName}/data-mariadb
			chown -R 0:0 ${stacksDataRoot}/${packageName}/data-mariadb
			
			mkdir -p ${stacksDataRoot}/${packageName}/data-davis
			chown -R ${UID}:${GID} ${stacksDataRoot}/${packageName}/data-davis
		'';
		
		networking.firewall.allowedTCPPorts = [ 8000 ];
		networking.firewall.allowedUDPPorts = [ 8000 ];
	};
}