{ config, lib, pkgs, modulesPath, ... }:
{
	age.secrets."wgKey-server-public.age".file = ../../../secrets/wgKey-server-public.age;
	age.secrets."wgKey-server-private.age".file = ../../../secrets/wgKey-server-private.age;
	age.secrets."wgKey-dan-public.age".file = ../../../secrets/wgKey-dan-public.age;
	age.secrets."wgKey-lindsey-office-public.age".file = ../../../secrets/wgKey-lindsey-office-public.age;
	age.secrets."wgKey-lindsey-remote-public.age".file = ../../../secrets/wgKey-lindsey-remote-public.age;
	age.secrets."wgKey-janine-office-public.age".file = ../../../secrets/wgKey-janine-office-public.age;
	age.secrets."wgKey-janine-remote-public.age".file = ../../../secrets/wgKey-janine-remote-public.age;
	age.secrets."wgKey-carolyn-office-public.age".file = ../../../secrets/wgKey-carolyn-office-public.age;
	age.secrets."wgKey-carolyn-remote-public.age".file = ../../../secrets/wgKey-carolyn-remote-public.age;
	age.secrets."wgKey-tetrodesign-public.age".file = ../../../secrets/wgKey-tetrodesign-public.age;
	# age.secrets."wgKey-subscriptionmachine-public.age".file = ../../../secrets/wgKey-subscriptionmachine-public.age;
}