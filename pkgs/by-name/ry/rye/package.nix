{
  lib,
  rustPlatform,
  fetchFromGitHub,

  # nativeBuildInputs
  installShellFiles,
  pkg-config,

  # buildInputs
  openssl,
  stdenv,

  buildPackages,
  versionCheckHook,

  # passthru
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "rye";
  version = "0.44.0";

  src = fetchFromGitHub {
    owner = "mitsuhiko";
    repo = "rye";
    tag = version;
    hash = "sha256-K9xad5Odza0Oxz49yMJjqpfh3cCgmWnbAlv069fHV6Q=";
  };

  cargoHash = "sha256-+gFa8hruXIweFm24XvfhqXZxNLAYKVNX+xBSCdAk54A=";

  env = {
    OPENSSL_NO_VENDOR = 1;
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  postInstall =
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd rye \
        --bash <(${emulator} $out/bin/rye self completion -s bash) \
        --fish <(${emulator} $out/bin/rye self completion -s fish) \
        --zsh <(${emulator} $out/bin/rye self completion -s zsh)
    '';

  checkFlags = [
    "--skip=utils::test_is_inside_git_work_tree"

    # The following require internet access to fetch a python binary
    "--skip=test_add_and_sync_no_auto_sync"
    "--skip=test_add_autosync"
    "--skip=test_add_dev"
    "--skip=test_add_explicit_version_or_url"
    "--skip=test_add_flask"
    "--skip=test_add_from_find_links"
    "--skip=test_autosync_remember"
    "--skip=test_basic_list"
    "--skip=test_basic_script"
    "--skip=test_basic_tool_behavior"
    "--skip=test_config_empty"
    "--skip=test_config_get_set_multiple"
    "--skip=test_config_incompatible_format_and_show_path"
    "--skip=test_config_save_missing_folder"
    "--skip=test_config_show_path"
    "--skip=test_dotenv"
    "--skip=test_empty_sync"
    "--skip=test_exclude_hashes"
    "--skip=test_fetch"
    "--skip=test_generate_hashes"
    "--skip=test_init_default"
    "--skip=test_init_lib"
    "--skip=test_init_script"
    "--skip=test_lint_and_format"
    "--skip=test_list_never_overwrite"
    "--skip=test_list_not_rye_managed"
    "--skip=test_lockfile"
    "--skip=test_publish_outside_project"
    "--skip=test_version"
  ];

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tool to easily manage python dependencies and environments";
    homepage = "https://github.com/mitsuhiko/rye";
    changelog = "https://github.com/mitsuhiko/rye/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "rye";
  };
}
