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
		
		age.secrets."davis-env.age".file = ../../secrets/davis-env.age;
		
		
		environment.etc."stacks/${packageName}/compose.yaml".text =
		/* yaml */
		''
services:
  ${packageName}-postgres:
    image: postgres:16
    container_name: ${packageName}-postgres
    user: "${UID}:${GID}"
    environment:
      PUID: ${UID}
      PGID: ${GID}
      POSTGRES_PASSWORD: ''${DB_PASSWORD}
      POSTGRES_DB: ''${DB_DATABASE}
      POSTGRES_USER: ''${DB_USER}
    volumes:
      - ${stacksDataRoot}/${packageName}/data-postgres:/var/lib/postgresql/data

  ${packageName}:
    image: ghcr.io/tchapi/davis-standalone:5.0.2
    container_name: ${packageName}
    user: "${UID}:${GID}"
    environment:
      PUID: ${UID}
      PGID: ${GID}
      APP_ENV: prod
      DATABASE_DRIVER: postgresql
      DATABASE_URL: postgresql://''${DB_USER}:''${DB_PASSWORD}@${packageName}-postgres:5432/''${DB_DATABASE}?serverVersion=15&charset=UTF-8
      #MAILER_DSN: smtp://''${MAIL_USERNAME}:''${MAIL_PASSWORD}@''${MAIL_HOST}:''${MAIL_PORT}
      ADMIN_LOGIN: ''${ADMIN_LOGIN}
      ADMIN_PASSWORD: ''${ADMIN_PASSWORD}
      AUTH_REALM: ''${AUTH_REALM}
      AUTH_METHOD: ''${AUTH_METHOD}
      CALDAV_ENABLED: ''${CALDAV_ENABLED}
      CARDDAV_ENABLED: ''${CARDDAV_ENABLED}
      WEBDAV_ENABLED: ''${WEBDAV_ENABLED}
      WEBDAV_TMP_DIR: ''${WEBDAV_TMP_DIR}
      WEBDAV_PUBLIC_DIR: ''${WEBDAV_PUBLIC_DIR}
      WEBDAV_HOMES_DIR: ''${WEBDAV_HOMES_DIR}
      INVITE_FROM_ADDRESS: ''${INVITE_FROM_ADDRESS}
      APP_TIMEZONE: ''${TIMEZONE}
    volumes:
      - ${stacksDataRoot}/${packageName}/data-davis:/data
    ports:
      - 9900:9000

'';
		
		systemd.services."${packageName}" = {
			wantedBy = ["multi-user.target"];
			after = ["docker.service" "docker.socket"];
			path = [pkgs.docker];
			script = ''
				docker compose --env-file ${config.age.secrets."davis-env.age".path} -f /etc/stacks/${packageName}/compose.yaml up --remove-orphans
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