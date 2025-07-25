{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  pkg-config,
  withNativeTls ? true,
  stdenv,
  openssl,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xh";
  version = "0.24.1";

  src = fetchFromGitHub {
    owner = "ducaale";
    repo = "xh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2c96O5SL6tcPSbxx8NYxG8LDX3ZgyxEMmEeJnKDwb38=";
  };

  cargoHash = "sha256-oncf3Hd85LgKn8KSDIBHXLJ3INzfp0X/Ng9OjAltLB4=";

  buildFeatures = lib.optional withNativeTls "native-tls";

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = lib.optionals (withNativeTls && !stdenv.hostPlatform.isDarwin) [ openssl ];

  env = {
    # Get openssl-sys to use pkg-config
    OPENSSL_NO_VENDOR = 1;
  };

  postInstall = ''
    installShellCompletion \
      completions/xh.{bash,fish} \
      --zsh completions/_xh

    installManPage doc/xh.1
    ln -s $out/share/man/man1/xh.1 $out/share/man/man1/xhs.1

    install -m444 -Dt $out/share/doc/xh README.md CHANGELOG.md

    ln -s $out/bin/xh $out/bin/xhs
  '';

  # Nix build happens in sandbox without internet connectivity
  # disable tests as some of them require internet due to nature of application
  doCheck = false;
  doInstallCheck = true;
  postInstallCheck = ''
    $out/bin/xh --help > /dev/null
    $out/bin/xhs --help > /dev/null
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Friendly and fast tool for sending HTTP requests";
    homepage = "https://github.com/ducaale/xh";
    changelog = "https://github.com/ducaale/xh/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      figsoda
      defelo
    ];
    mainProgram = "xh";
  };
})
