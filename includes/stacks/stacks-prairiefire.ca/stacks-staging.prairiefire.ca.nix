{ config, lib, pkgs, modulesPath, ... }:
let
	packageName = "davis";
	UID = "0";
	GID = "0";
	stacksDataRoot = "/mnt/DOCUMENTS-01/stacks";
in
{
	options.local.stacks."staging.prairiefire.ca".enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
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
			mkdir -p ${stacksDataRoot}/${packageName}/data-postgres
			chown -R 999:999 ${stacksDataRoot}/${packageName}/data-postgres
			
			mkdir -p ${stacksDataRoot}/${packageName}/data-davis
			chown -R ${UID}:${GID} ${stacksDataRoot}/${packageName}/data-davis
		'';
		
		networking.firewall.allowedTCPPorts = [ 9900 ];
		#networking.firewall.allowedUDPPorts = [ 9900 ];
	};
}