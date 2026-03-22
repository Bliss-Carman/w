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
		

		# REMOTE BACKUP
		#systemctl list-timers
		local.backup.secrets.enable = lib.mkForce true;
		age.secrets."backup-s3cfg-prairiefire.ca.age".file = ../../../secrets/backup-s3cfg-prairiefire.ca.age;

		environment.interactiveShellInit = ''
			alias do-backup-prairiefire-ca-weekly='systemctl --verbose start stack-prairiefire.ca-s3-backup-weekly.service'
			alias do-backup-prairiefire-ca-monthly='systemctl --verbose start stack-prairiefire.ca-s3-backup-monthly.service'
			alias do-backup-prairiefire-ca-bi-annually='systemctl --verbose start stack-prairiefire.ca-s3-backup-bi-annually.service'
		'';


		# Weekly
		systemd.services."${packageName}-s3-backup-weekly" = {
			script = ''
set -o errexit
set -o nounset
set -o pipefail
${pkgs.gnutar}/bin/tar cvf - --use-compress-program=${pkgs.xz}/bin/xz \
	${stacksDataRoot}/${packageName} | \
	${pkgs.age}/bin/age --recipients-file ${config.age.secrets."backup-encrypted-recipients.age".path} | \
	${pkgs.s3cmd}/bin/s3cmd --verbose --config=${config.age.secrets."backup-s3cfg-prairiefire.ca.age".path} put - \
	s3://PFWebBackups/${config.networking.hostName}-${packageName}-weekly.tar.xz.age || true
  '';
			serviceConfig = {
				Type = "oneshot";
				User = "root";
				Nice = 19;
				IOSchedulingClass = "idle";
				IOSchedulingPriority=7;
			};
		};

		systemd.timers."${packageName}-s3-backup-weekly" = {
			wantedBy = [ "timers.target" ];
			timerConfig = {
				OnCalendar = "Mon *-*-* 01:00:00 America/Winnipeg";
				Unit = "${packageName}-s3-backup-weekly.service";
				Persistent = true;
			};
		};

		# Monthly
		systemd.services."${packageName}-s3-backup-monthly" = {
			script = ''
set -o errexit
set -o nounset
set -o pipefail
${pkgs.gnutar}/bin/tar cvf - --use-compress-program=${pkgs.xz}/bin/xz \
	${stacksDataRoot}/${packageName} | \
	${pkgs.age}/bin/age --recipients-file ${config.age.secrets."backup-encrypted-recipients.age".path} | \
	${pkgs.s3cmd}/bin/s3cmd --verbose --config=${config.age.secrets."backup-s3cfg-prairiefire.ca.age".path} put - \
	s3://PFWebBackups/${config.networking.hostName}-${packageName}-monthly.tar.xz.age || true
  '';
			serviceConfig = {
				Type = "oneshot";
				User = "root";
				Nice = 19;
				IOSchedulingClass = "idle";
				IOSchedulingPriority=7;
			};
		};

		systemd.timers."${packageName}-s3-backup-monthly" = {
			wantedBy = [ "timers.target" ];
			timerConfig = {
				OnCalendar = "*-*-02 01:00:00 America/Winnipeg";
				Unit = "${packageName}-s3-backup-monthly.service";
				Persistent = true;
			};
		};



		# Bi-Annually
		systemd.services."${packageName}-s3-backup-bi-annually" = {
			script = ''
set -o errexit
set -o nounset
set -o pipefail
${pkgs.gnutar}/bin/tar cvf - --use-compress-program=${pkgs.xz}/bin/xz \
	${stacksDataRoot}/${packageName} | \
	${pkgs.age}/bin/age --recipients-file ${config.age.secrets."backup-encrypted-recipients.age".path} | \
	${pkgs.s3cmd}/bin/s3cmd --verbose --config=${config.age.secrets."backup-s3cfg-prairiefire.ca.age".path} put - \
	s3://PFWebBackups/${config.networking.hostName}-${packageName}-bi-annually.tar.xz.age || true
  '';
			serviceConfig = {
				Type = "oneshot";
				User = "root";
				Nice = 19;
				IOSchedulingClass = "idle";
				IOSchedulingPriority=7;
			};
		};

		systemd.timers."${packageName}-s3-backup-bi-annually" = {
			wantedBy = [ "timers.target" ];
			timerConfig = {
				OnCalendar = [
					"*-01-01 01:00:00 America/Winnipeg"
					"*-07-01 01:00:00 America/Winnipeg"
				];
				Unit = "${packageName}-s3-backup-bi-annually.service";
				Persistent = true;
			};
		};


		# DOCKER


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
			chown -R 999:999 ${stacksDataRoot}/${packageName}/data-mariadb

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