{ config, lib, pkgs, modulesPath, ... }:
let
	packageName = "stack-rustdesk-server";
	UID = "0";
	GID = "0";
	stacksDataRoot = "/stacks";
in
{
	options.local.stacks."rustdesk-server".enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.stacks."rustdesk-server".enable {
		

		# REMOTE BACKUP
		#systemctl list-timers
		local.backup.secrets.enable = lib.mkForce true;
		age.secrets."backup-s3cfg-rustdesk-server.age".file = ../../../secrets/backup-s3cfg-rustdesk-server.age;

		environment.interactiveShellInit = ''
			alias do-backup-rustdesk-server-weekly='systemctl start stack-rustdesk-server-s3-backup-weekly.service'
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
	${pkgs.s3cmd}/bin/s3cmd --verbose --config=${config.age.secrets."backup-s3cfg-rustdesk-server.age".path} put - \
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
				OnCalendar = "Wed *-*-* 01:00:00 America/Winnipeg";
				Unit = "${packageName}-s3-backup-weekly.service";
				Persistent = true;
			};
		};




		# DOCKER


		environment.etc."stacks/${packageName}/compose.yaml".text = (
			builtins.replaceStrings [
					''''${packageName}''
					''''${stacksDataRoot}''
				] 
				[
					packageName
					stacksDataRoot
				] 
				(builtins.readFile ./compose.yml)
			)
		;
		
		systemd.services."${packageName}" = {
			wantedBy = ["multi-user.target"];
			after = ["docker.service" "docker.socket"];
			path = [pkgs.docker];
			script = ''
				docker compose -f /etc/stacks/${packageName}/compose.yaml up --remove-orphans
			'';
			restartTriggers = [
				config.environment.etc."stacks/${packageName}/compose.yaml".source
			];
		};
		
		system.activationScripts.makeRustdeskDirs = lib.stringAfter [ "var" ] ''
			mkdir -p ${stacksDataRoot}/${packageName}/data
			chown -R 0:0 ${stacksDataRoot}/${packageName}/data
		'';
		
		networking.firewall.allowedTCPPorts = [ 21114 21115 21116 21118 21117 21119 ];
		networking.firewall.allowedUDPPorts = [ 21116 ];
	};
}