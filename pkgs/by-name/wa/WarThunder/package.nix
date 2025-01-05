{ stdenv, lib, fetchurl, makeDesktopItem, libgcc, xorg, makeWrapper, patchelf, gtk3, glib, pkgs, autoPatchelfHook }:


let
#pkgs = import <nixpkgs> {};
  libPath = lib.makeLibraryPath ([
    libgcc
    gtk3
    glib
    pkgs.xorg.libX11
    pkgs.xorg.libXrandr
    stdenv.cc.cc.lib
    stdenv.cc.cc
    pkgs.libgcc
  ] ++ (with xorg; [pkgs.xorg.libX11 pkgs.xorg.libXrandr]));
  in

stdenv.mkDerivation rec {
  name = "launcher";
  pname = "War-Thunder";
  version = "086d99e";

  src = fetchurl {
    url = "https://github.com/Mephist0phel3s/War-Thunder/archive/refs/tags/086d99e.tar.gz";
    hash = "sha256-vqpx85ZT1AzKk7dkZvMDMJf9GWalDM/F2JhaiMybMoY=";
  };

  nativeBuildInputs = [ stdenv.cc.cc makeWrapper autoPatchelfHook ];
  buildInputs = [stdenv.cc.cc makeWrapper gtk3 glib makeDesktopItem] ++ (with xorg; [xorg.libX11 xorg.libXrandr]);
  sourceRoot = "./${pname}-${version}";
  unpackPhase = false;
  dontConfigure = true;
  dontBuild = false;

 installPhase = ''
  install -m755 -D launcher $out/${pname}-${version}/launcher
  install -m755 -D gaijin_selfupdater $out/${pname}-${version}/gaijin_selfupdater
  install -m755 -D bpreport $out/${pname}-${version}/bpreport
  install -m755 -D launcher.ico $out/${pname}-${version}/icon.png
  cp ca-bundle.crt $out/${pname}-${version}/ca-bundle.crt
  cp launcherr.dat $out/${pname}-${version}/launcherr.dat
  cp libsciter-gtk.so $out/${pname}-${version}/libsciter-gtk.so
  cp libsteam_api.so $out/${pname}-${version}/libsteam_api.so
  cp package.blk $out/${pname}-${version}/package.blk
  cp yupartner.blk $out/${pname}-${version}/yupartner.blk
  '';

  postInstall = ''
  runHook preInstall

  chmod +x $out/${pname}-${version}/launcher
  x=${pname}-${version}/launcher
  chmod +x $x
  patchelf \
    --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
    --set-rpath $libPath \
  $x  $out/${pname}-${version}/gaijin_selfupdater $out/${pname}-${version}/bpreport
  mkdir -p $out/${pname}-${version}/opt/wrapper
  makeWrapper $x $out/${pname}-${version}/opt/wrapper/launcher-wrapped --prefix LD_LIBRARY_PATH $libPath --run 'cd $libPath'
  install -m755 -D $out/${pname}-${version}/opt/wrapper/launcher-wrapped $out/${pname}-${version}/launcher-wrapped

  runHook postInstall

  chmod +x $out/${pname}-${version}/launcher-wrapped


  install -D m755 $desktopEntry "$out/${pname}.desktop"

  '';



  meta = with lib; {
    homepage = "https://warthunder.com/";
    description = "Military Vehicle PVP simulator, tanks, planes, warships";
    platforms = platforms.linux;
  };
}
