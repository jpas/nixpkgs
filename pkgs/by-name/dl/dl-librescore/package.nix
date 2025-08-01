{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  python3,
  cctools,
}:

buildNpmPackage rec {
  pname = "dl-librescore";
  version = "0.35.29";

  src = fetchFromGitHub {
    owner = "LibreScore";
    repo = "dl-librescore";
    rev = "v${version}";
    hash = "sha256-DwDlGTFdqAAsEWrhnieuaeYQ0N8COB/7b49xPJackJQ=";
  };

  npmDepsHash = "sha256-5Uc83VdqMwQaTSmzwpBh7x4IKoVPd9MYDXkDvR1fz6Q=";

  # see https://github.com/LibreScore/dl-librescore/pull/32
  # TODO can be removed with next update
  postPatch = ''
    substituteInPlace package-lock.json \
      --replace 50c7a1508cd9358757c30794e14ba777e6faa8aa b4cb32eb1734a2f73ba2d92743647b1a91c0e2a8
  '';

  makeCacheWritable = true;

  nativeBuildInputs = [
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cctools
  ];

  meta = {
    description = "Download sheet music";
    homepage = "https://github.com/LibreScore/dl-librescore";
    license = lib.licenses.mit;
    mainProgram = "dl-librescore";
    maintainers = [ ];
  };
}
