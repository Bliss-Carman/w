{ lib
, stdenvNoCC
, makeDesktopItem
}:

stdenvNoCC.mkDerivation {
	
	name = "sftp-tetro";
	src = ./.;

	installPhase = ''
	cp -rv $src $out
	'';

}