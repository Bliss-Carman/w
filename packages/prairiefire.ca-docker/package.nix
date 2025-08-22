{ lib
, stdenvNoCC
, makeDesktopItem
}:

stdenvNoCC.mkDerivation {
	
	name = "staging.prairiefire.ca-docker";
	src = ./.;

	installPhase = ''
	cp -rv $src $out
	'';

}