{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  fuse,
  android-tools,
}:

stdenv.mkDerivation rec {
  pname = "adbfs-rootless";
  version = "0-unstable-2023-03-21";

  src = fetchFromGitHub {
    owner = "spion";
    repo = "adbfs-rootless";
    rev = "fd56381af4dc9ae2f09b904c295686871a46ed0f";
    sha256 = "atiVjRfqvhTlm8Q+3iTNNPQiNkLIaHDLg5HZDJvpl2Q=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ fuse ];

  postPatch = ''
    # very ugly way of replacing the adb calls
    substituteInPlace adbfs.cpp \
      --replace '"adb ' '"${android-tools}/bin/adb '
  '';

  installPhase = ''
    runHook preInstall
    install -D adbfs $out/bin/adbfs
    runHook postInstall
  '';

  meta = {
    description = "Mount Android phones on Linux with adb, no root required";
    mainProgram = "adbfs";
    inherit (src.meta) homepage;
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
  };
}
