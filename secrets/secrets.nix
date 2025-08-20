# Do not do this!
# config.password = builtins.readFile config.age.secrets.secret1.path;
# ssh-keyscan localhost
# agenix -e fileserver-smb.age
# agenix --rekey
let
	user-dan = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4DXCWnspO5WUrirR33EAGTIl692+COgeds0Tvtw6Yd"];
	user-lindsey = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEX9irGef8dhKeboc/4ry2P3nliXz0wLjKMP9FANAfb3" # Lindsey Home Office
		"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDmlKthJNoPPW9F8yYZGj9rtQI1mqf26ddF2qU6shD1Kho/5/1x+3B3Z1mwyGXQfLyeB+E3bx7lLh+OTXIyUYxTOj4zxOylCt2HXcOZlGA2FjM8Cx4iGwrNa7wVhPyZGbmLd7n4IQvf9iSqNcGAuD3jyeXsqbcExs3PLGnhyFPH7ptk1EnviGDZ89FV2XA4P01G/beI/t4NmwTcSHfl3WPxKFKuWeCED6InHLKMnhJkqDb2AzF0cSp3IZweS9YEvOI+YBFtvAeZAP0ls5wCxtHjE1p9bZcPgWt+7o9mV2uAOMzdK5c0RljYySEUcpX4NQBOglQVeD3gUCecTHHIkDMkJpXdIcfp2IuPn1vup44R9yR8+J73rTzype+DKx64sRbOG9s6GL1/lPUsaojDthS2fPCFtjeDQY1uJeaZvhscBYkktwQXp9Qrpnqq2GVR26uV7Jp/9EzynNeizXz3DkrLhS7h4D9qlrX4OHPUUckoV8bbqYNTXnkrTNcvdGAJZY0= prairiefire@Lindseys-iMac.local" # Lindsey Office
	];
	users = [ ] ++ user-dan ++ user-lindsey;
	users-admin = [ ] ++  user-dan ++ user-lindsey;

	system-pfweb-staging = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH1GuHAFiaOYtI/s5ulMwXwXQAmtLaSROLo1MniHvxed";
	
	systems-servers = [
		system-pfweb-staging
	];
	
	systems-all = [] ++ systems-servers;
	
in
{
	"userHashedPasswordFile-dan.age".publicKeys = systems-all ++ users-admin ++ user-dan;
	"userHashedPasswordFile-lindsey.age".publicKeys = systems-all ++ users-admin ++ user-lindsey;
	"userHashedPasswordFile-root.age".publicKeys = systems-all ++ users-admin;
	"userHashedPasswordFile-tetrodesign.age".publicKeys = systems-all ++ users-admin;
	"wgKey-server-public.age".publicKeys = systems-all ++ users-admin;
	"wgKey-server-private.age".publicKeys = systems-servers ++ users-admin;
	"wgKey-dan-public.age".publicKeys = systems-all ++ users-admin;
	"wgKey-dan-private.age".publicKeys = users-admin;
	"wgKey-lindsey-office-public.age".publicKeys = systems-all ++ users-admin;
	"wgKey-lindsey-office-private.age".publicKeys = users-admin;
	"wgKey-lindsey-remote-public.age".publicKeys = systems-all ++ users-admin;
	"wgKey-lindsey-remote-private.age".publicKeys = users-admin;
	"wgKey-janine-office-public.age".publicKeys = systems-all ++ users-admin;
	"wgKey-janine-office-private.age".publicKeys = users-admin;
	"wgKey-janine-remote-public.age".publicKeys = systems-all ++ users-admin;
	"wgKey-janine-remote-private.age".publicKeys = users-admin;
	"wgKey-carolyn-office-public.age".publicKeys = systems-all ++ users-admin;
	"wgKey-carolyn-office-private.age".publicKeys = users-admin;
	"wgKey-carolyn-remote-public.age".publicKeys = systems-all ++ users-admin;
	"wgKey-carolyn-remote-private.age".publicKeys = users-admin;
	"wgKey-tetrodesign-public.age".publicKeys = systems-all ++ users-admin;
	"wgKey-tetrodesign-private.age".publicKeys = users-admin;
	"dns-linode.age".publicKeys = systems-all ++ users-admin;
	"mysql-root-password.age".publicKeys = systems-all ++ users-admin ++ user-dan;
	"prairiefire.ca-env.age".publicKeys = systems-all ++ users-admin ++ user-dan;
}