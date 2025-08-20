{ lib
, stdenvNoCC
, makeDesktopItem
}:

stdenvNoCC.mkDerivation {
	
	name = "stack-prairiefire.ca-dependencies";
	src = ./.;

	installPhase = ''
	cp -rv $src $out
	'';

}