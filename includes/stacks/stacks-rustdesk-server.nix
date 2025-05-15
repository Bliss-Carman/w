{ config, lib, pkgs, modulesPath, ... }:
let
	packageName = "davis";
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
		
		
		age.secrets."davis-env.age".file = ../../secrets/davis-env.age;
		
		
		environment.etc."stacks/${packageName}/compose.yaml".text =
		/* yaml */
		''
services:
  hbbs:
    container_name: hbbs
    image: rustdesk/rustdesk-server:latest
    command: hbbs
    volumes:
      - ./data:/root
    ports:
      - 21114:21114/tcp
      - 21115:21115/tcp
      - 21116:21116/tcp
      - 21118:21118/tcp
      - 21116:21116/udp
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
      - ./data:/root
    ports:
      - 21117:21117/tcp
      - 21119:21119/tcp
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