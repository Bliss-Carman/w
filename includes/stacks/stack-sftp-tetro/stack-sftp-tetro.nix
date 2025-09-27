{ config, lib, pkgs, modulesPath, ... }:
let
	packageName = "stack-sftp";
	UID = "0";
	GID = "0";
	stacksDataRoot = "/stacks";

	dockerContext = (pkgs.callPackage ../../../packages/stack-sftp/package.nix {});
in
{
	options.local.stacks."sftp-tetro".enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.stacks."sftp-tetro".enable {

		age.secrets."sftp-tetro-host-key-ecdsa-private.age".file = ../../secrets/sftp-tetro-host-key-ecdsa-private.age;
		age.secrets."sftp-tetro-host-key-ecdsa-public.age".file = ../../secrets/sftp-tetro-host-key-ecdsa-public.age;
		age.secrets."sftp-tetro-host-key-ed25519-private.age".file = ../../secrets/sftp-tetro-host-key-ed25519-private.age;
		age.secrets."sftp-tetro-host-key-ed25519-public.age".file = ../../secrets/sftp-tetro-host-key-ed25519-public.age;
		age.secrets."sftp-tetro-host-key-rsa-private.age".file = ../../secrets/sftp-tetro-host-key-rsa-private.age;
		age.secrets."sftp-tetro-host-key-rsa-public.age".file = ../../secrets/sftp-tetro-host-key-rsa-public.age;
		age.secrets."sftp-tetro-env.age".file = ../../secrets/sftp-tetro-env.age;
		





		environment.etc."stacks/${packageName}/compose.yaml".text = (
			builtins.replaceStrings [
					''''${packageName}''
					''''${stacksDataRoot}''
					''''${dockerContext}''
					''''${SECRET_PATH_sftp-tetro-host-key-ecdsa-private}''
					''''${SECRET_PATH_sftp-tetro-host-key-ecdsa-public}''
					''''${SECRET_PATH_sftp-tetro-host-key-ed25519-private}''
					''''${SECRET_PATH_sftp-tetro-host-key-ed25519-public}''
					''''${SECRET_PATH_sftp-tetro-host-key-rsa-private}''
					''''${SECRET_PATH_sftp-tetro-host-key-rsa-public}''
				] 
				[
					packageName
					stacksDataRoot
					"${dockerContext}"
					config.age.secrets."sftp-tetro-host-key-ecdsa-private.age".path
					config.age.secrets."sftp-tetro-host-key-ecdsa-public.age".path
					config.age.secrets."sftp-tetro-host-key-ed25519-private.age".path
					config.age.secrets."sftp-tetro-host-key-ed25519-public.age".path
					config.age.secrets."sftp-tetro-host-key-rsa-private.age".path
					config.age.secrets."sftp-tetro-host-key-rsa-public.age".path
				] 
				(builtins.readFile ./compose.yml)
			)
		;
		
		systemd.services."${packageName}" = {
			wantedBy = ["multi-user.target"];
			after = ["docker.service" "docker.socket"];
			path = [pkgs.docker];
			script = ''
				docker compose --env-file ${config.age.secrets."sftp-tetro-env.age".path} -f /etc/stacks/${packageName}/compose.yaml up --remove-orphans
			'';
			restartTriggers = [
				config.environment.etc."stacks/${packageName}/compose.yaml".source
			];
		};
		
		# system.activationScripts.makeSftpServerDirs = lib.stringAfter [ "var" ] ''
		# 	mkdir -p ${stacksDataRoot}/${packageName}/data
		# 	chown -R 0:0 ${stacksDataRoot}/${packageName}/data
		# '';
		
		# networking.firewall.allowedTCPPorts = [ 8100 ];
		# networking.firewall.allowedUDPPorts = [ 8100 ];
	};
}