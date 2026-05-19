* ```nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable```
* ```nix-channel --add https://github.com/ryantm/agenix/archive/main.tar.gz agenix```
* ```nix-channel --update```
* ```journalctl -u acme-staging.prairiefire.ca.service --follow```
* ```journalctl -u acme-prairiefire.ca.service --follow```
* ```rm public.txt private.txt; umask 077 && wg genkey > private.txt && wg pubkey < private.txt > public.txt```
rm -rf /var/lib/acme*

prelim self signed acme-prairiefire.ca.service

systemctl status acme-order-renew-prairiefire.ca.service

journalctl -u acme-order-renew-prairiefire.ca.service -f
journalctl -u acme-order-renew-staging.prairiefire.ca.service -f
journalctl -u acme-order-renew-admin.prairiefire.ca.service -f

systemctl start acme-order-renew-admin.prairiefire.ca.service
systemctl start acme-order-renew-prairiefire.ca.service
systemctl start acme-order-renew-staging.prairiefire.ca.service

while openssl x509 -noout -text; do :; done < cert.pem