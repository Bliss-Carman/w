{ config, lib, pkgs, modulesPath, ... }:
{
	options.local.services.wireguard-server.enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.local.services.wireguard-server.enable {
		# enable NAT
		networking.nat.enable = true;
		networking.nat.externalInterface = "enp1s0";
		networking.nat.internalInterfaces = ["wg0"];
		networking.firewall = {
			allowedUDPPorts = [ 51820 ];
		};

		networking.wireguard.enable = true;
		networking.wireguard.interfaces = {
			# "wg0" is the network interface name. You can name the interface arbitrarily.
			wg0 = {
				# Determines the IP address and subnet of the server's end of the tunnel interface.
				ips = [
					"172.16.100.1/24"
				];

				# The port that WireGuard listens to. Must be accessible by the client.
				listenPort = 51820;

				# This allows the wireguard server to route your traffic to the internet and hence be like a VPN
				# For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
				postSetup = ''
					${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 172.16.100.0/24 -o eth0 -j MASQUERADE
				'';

				# This undoes the above command
				postShutdown = ''
					${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 172.16.100.0/24 -o eth0 -j MASQUERADE
				'';

				privateKeyFile = config.age.secrets."wgKey-server-private.age".path;


				# rm public.txt private.txt; umask 077 && wg genkey > private.txt && wg pubkey < private.txt > public.txt

				peers = [
					{ # Dan (test)
						publicKey = builtins.readFile config.age.secrets."wgKey-dan-public.age".path;
						allowedIPs = [ "172.16.100.2/32" ];
					}
					{ # lindsey-office
						publicKey = builtins.readFile config.age.secrets."wgKey-lindsey-office-public.age".path;
						allowedIPs = [ "172.16.100.3/32" ];
					}
					{ # lindsey-remote
						publicKey = builtins.readFile config.age.secrets."wgKey-lindsey-remote-public.age".path;
						allowedIPs = [ "172.16.100.4/32" ];
					}
					{ # janine-office
						publicKey = builtins.readFile config.age.secrets."wgKey-janine-office-public.age".path;
						allowedIPs = [ "172.16.100.5/32" ];
					}
					{ # janine-remote
						publicKey = builtins.readFile config.age.secrets."wgKey-janine-remote-public.age".path;
						allowedIPs = [ "172.16.100.6/32" ];
					}
					{ # carolyn-office
						publicKey = builtins.readFile config.age.secrets."wgKey-carolyn-office-public.age".path;
						allowedIPs = [ "172.16.100.7/32" ];
					}
					{ # carolyn-remote
						publicKey = builtins.readFile config.age.secrets."wgKey-carolyn-remote-public.age".path;
						allowedIPs = [ "172.16.100.8/32" ];
					}
					{ # tetrodesign
						publicKey = builtins.readFile config.age.secrets."wgKey-tetrodesign-public.age".path;
						allowedIPs = [ "172.16.100.9/32" ];
					}
				];
			};
		};
	};
}