{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  pkg-config,
  expat,
  gettext,
  libiconv,
  dbus,
  glib,
}:

stdenv.mkDerivation rec {
  pname = "dbus-glib";
  version = "0.114";

  src = fetchurl {
    url = "${meta.homepage}/releases/dbus-glib/dbus-glib-${version}.tar.gz";
    sha256 = "sha256-wJxcCFsqDjkbjufXg6HWP+RE6WcXzBgU1htej8KCenw=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];
  outputBin = "dev";

  nativeBuildInputs = [
    pkg-config
    gettext
    glib
  ];

  buildInputs = [
    expat
    libiconv
  ];

  propagatedBuildInputs = [
    dbus
    glib
  ];

  configureFlags = [
    "--exec-prefix=${placeholder "dev"}"
  ]
  ++ lib.optional (
    stdenv.buildPlatform != stdenv.hostPlatform
  ) "--with-dbus-binding-tool=${buildPackages.dbus-glib.dev}/bin/dbus-binding-tool";

  doCheck = false;

  passthru = { inherit dbus glib; };

  meta = {
    homepage = "https://dbus.freedesktop.org";
    license = with lib.licenses; [
      afl21
      gpl2Plus
    ];
    description = "Obsolete glib bindings for D-Bus lightweight IPC mechanism";
    mainProgram = "dbus-binding-tool";
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
