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
		
		environment.etc."stacks/${packageName}/compose.yaml".text =
		/* yaml */
		''
services:
  hbbs:
    container_name: hbbs
    image: rustdesk/rustdesk-server:latest
    command: hbbs
    volumes:
      - ${stacksDataRoot}/${packageName}/data:/root
    ports:
      - 172.16.100.1:21114:21114/tcp
      - 172.16.100.1:21115:21115/tcp
      - 172.16.100.1:21116:21116/tcp
      - 172.16.100.1:21118:21118/tcp
      - 172.16.100.1:21116:21116/udp
    environment:
      ENCRYPTED_ONLY: 1
      PUID: ${UID}
      PGID: ${GID}
    depends_on:
      - hbbr
    restart: unless-stopped


  hbbr:
    container_name: hbbr
    image: rustdesk/rustdesk-server:latest
    command: hbbr
    volumes:
      - ${stacksDataRoot}/${packageName}/data:/root
    ports:
      - 172.16.100.1:21117:21117/tcp
      - 172.16.100.1:21119:21119/tcp
    environment:
      ENCRYPTED_ONLY: 1
      PUID: ${UID}
      PGID: ${GID}
    restart: unless-stopped
'';
		
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
		
		system.activationScripts.makeDavisDirs = lib.stringAfter [ "var" ] ''
			mkdir -p ${stacksDataRoot}/${packageName}/data
			chown -R 0:0 ${stacksDataRoot}/${packageName}/data
		'';
		
		networking.firewall.allowedTCPPorts = [ 21114 21115 21116 21118 21117 21119 ];
		networking.firewall.allowedUDPPorts = [ 21116 ];
	};
}