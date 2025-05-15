* ```nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable```
* ```nix-channel --add https://github.com/ryantm/agenix/archive/main.tar.gz agenix```
* ```nix-channel --update```
* ```journalctl -u acme-staging.prairiefire.ca.service --follow```
* ```journalctl -u acme-prairiefire.ca.service --follow```
* ```rm public.txt private.txt; umask 077 && wg genkey > private.txt && wg pubkey < private.txt > public.txt```