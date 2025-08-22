{ config, lib, pkgs, modulesPath, ... }:
let
	packageName = "stack-prairiefire.ca";
	UID = "0";
	GID = "0";
	stacksDataRoot = "/stacks";


	dockerContext = (pkgs.callPackage ../../../packages/prairiefire.ca-docker/package.nix {});
in
{
	options.local.stacks."prairiefire.ca".enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.stacks."prairiefire.ca".enable {
		local.services.httpd."www.prairiefire.ca".enable = lib.mkForce true;
		
		age.secrets."prairiefire.ca-env.age".file = ../../../secrets/prairiefire.ca-env.age;
		age.secrets."mysql-root-password.age".file = ../../../secrets/mysql-root-password.age;
		
		environment.etc."stacks/${packageName}/compose.yaml".text = (
			builtins.replaceStrings [
					''''${packageName}''
					''''${stacksDataRoot}''
					''''${MYSQL_ROOT_PASSWORD_FILE}''
					''''${dockerContext}''
				] 
				[
					packageName
					stacksDataRoot
					config.age.secrets."mysql-root-password.age".path
					"${dockerContext}"
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
		
		system.activationScripts.makeProdPFDirs = lib.stringAfter [ "var" ] ''
			mkdir -p ${stacksDataRoot}/${packageName}/data-mariadb
			chown -R 151:996 ${stacksDataRoot}/${packageName}/data-mariadb

			mkdir -p ${stacksDataRoot}/${packageName}/data-www-html
			chown -R 33:33 ${stacksDataRoot}/${packageName}/data-www-html
			find ${stacksDataRoot}/${packageName}/data-www-html -type d -exec chmod 755 {} \;
			find ${stacksDataRoot}/${packageName}/data-www-html -type f -exec chmod 644 {} \;

			if [[ ! -s "${stacksDataRoot}/${packageName}/php.ini" ]]; then
				cp "${dockerContext}/php.production.ini" "${stacksDataRoot}/${packageName}/php.ini"
			fi
		'';
		
		networking.firewall.allowedTCPPorts = [ 8003 ];
		networking.firewall.allowedUDPPorts = [ 8003 ];
	};
}