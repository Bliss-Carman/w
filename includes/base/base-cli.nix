{ config, lib, pkgs, modulesPath, ... }:

{
	imports = [
		../hardware/hardware-qemu-guest.nix

		../../secrets/backup-secrets.nix
		
		../network/network-cli.nix
		../network/network-browsers-cli.nix
		
		../services/services-acme.nix
		../services/services-reverse-proxy.nix
		../services/services-wireguard-server.nix
		../services/wireguard/wireguard-secrets.nix
		../services/services-sshd.nix

		../services/acme/acme-staging.prairiefire.ca.nix
		../services/acme/acme-prairiefire.ca.nix
		../services/acme/acme-admin.prairiefire.ca.nix
		
		../services/httpd/httpd-vhost-www.staging.prairiefire.ca.nix
		../services/httpd/httpd-vhost-phpmyadmin.staging.prairiefire.ca.nix
		../services/httpd/httpd-vhost-www.prairiefire.ca.nix
		../services/httpd/httpd-vhost-phpmyadmin.prairiefire.ca.nix
		
		../stacks/stack-staging.prairiefire.ca/stack-staging.prairiefire.ca.nix
		../stacks/stack-prairiefire.ca/stack-prairiefire.ca.nix
		../stacks/stack-rustdesk-server/stack-rustdesk-server.nix
		../stacks/stack-sftp-tetro/stack-sftp-tetro.nix

		../system/system-nixos-agenix.nix
		../system/system-nixos.nix
		../system/system-overcommit-memory.nix
		../system/system-runtimes-docker.nix
		
		../utilities/utilities-file-extractors.nix
		../utilities/utilities-file-maintenance.nix
		../utilities/utilities-hardware-cli.nix
		../utilities/utilities-processes.nix
		
		../../users/usersandgroups.nix
	];
	
	# Locale
	time.timeZone = "America/Winnipeg";
	i18n.defaultLocale = "en_CA.UTF-8";
	
	security.pam.loginLimits = [
		{
			domain = "*";
			type = "soft";
			item = "nofile";
			value = "8192";
		}
	];
	
	# Expected Packages
	environment.systemPackages = with pkgs; [
		util-linux
		git
	];



	# Configuration backup.

	local.backup.secrets.enable = lib.mkForce true;
	age.secrets."backup-s3cfg-nixos-config.age".file = ../../../secrets/backup-s3cfg-nixos-config.age;

	environment.interactiveShellInit = ''
		alias do-backup-nixos-config-weekly='systemctl --verbose start nixos-config-s3-backup-weekly.service'
	'';

	systemd.services."nixos-config-s3-backup-weekly" = {
			script = ''
set -o errexit
set -o nounset
set -o pipefail
${pkgs.gnutar}/bin/tar cvf - --use-compress-program=${pkgs.xz}/bin/xz \
	/etc/nixos | \
	${pkgs.age}/bin/age --recipients-file ${config.age.secrets."backup-encrypted-recipients.age".path} | \
	${pkgs.s3cmd}/bin/s3cmd --verbose --config=${config.age.secrets."backup-s3cfg-nixos-config.age".path} put - \
	s3://PFWebBackups/${config.networking.hostName}-nixos-config-weekly.tar.xz.age || true
  '';
			serviceConfig = {
				Type = "oneshot";
				User = "root";
				Nice = 19;
				IOSchedulingClass = "idle";
				IOSchedulingPriority=7;
			};
		};

		systemd.timers."nixos-config-s3-backup-weekly" = {
			wantedBy = [ "timers.target" ];
			timerConfig = {
				OnCalendar = "Mon *-*-* 01:00:00 America/Winnipeg";
				Unit = "nixos-config-s3-backup-weekly.service";
				Persistent = true;
			};
		};


}
