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