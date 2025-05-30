{
  stdenv,
  lib,
  fetchFromGitHub,
  buildGoModule,
  protoc-gen-grpc-web,
  protoc-gen-js,
  protobuf,
  tantivy-go,
}:

let
  pname = "anytype-heart";
  # Use only versions specified in anytype-ts middleware.version file:
  #  https://github.com/anyproto/anytype-ts/blob/v<anytype-ts-version>/middleware.version
  version = "0.40.21";
  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "anytype-heart";
    tag = "v${version}";
    hash = "sha256-53LSaETzxwhKkI9is6N6G1+f5Cnf7KStvHA9qeaWUNo=";
  };

  arch =
    {
      # https://github.com/anyproto/anytype-heart/blob/f33a6b09e9e4e597f8ddf845fc4d6fe2ef335622/pkg/lib/localstore/ftsearch/ftsearchtantivy.go#L3
      x86_64-linux = "linux-amd64-musl";
      aarch64-linux = "linux-arm64-musl";
      x86_64-darwin = "darwin-amd64";
      aarch64-darwin = "darwin-arm64";
    }
    .${stdenv.hostPlatform.system}
      or (throw "anytype-heart not supported on ${stdenv.hostPlatform.system}");

in
buildGoModule {
  inherit pname version src;

  vendorHash = "sha256-WsYRkAIYDkKWkQpq843dD7Rqc993eHSgee2IX6PomcU=";

  subPackages = [ "cmd/grpcserver" ];
  tags = [
    "nosigar"
    "nowatchdog"
  ];

  env.CGO_ENABLED = 1;
  proxyVendor = true;

  nativeBuildInputs = [
    protoc-gen-grpc-web
    protoc-gen-js
    protobuf
  ];

  preBuild = ''
    mkdir -p deps/libs/${arch}
    cp ${tantivy-go}/lib/libtantivy_go.a deps/libs/${arch}
  '';

  postBuild = ''
    protoc -I ./  --js_out=import_style=commonjs,binary:./dist/js/pb pb/protos/service/*.proto pb/protos/*.proto pkg/lib/pb/model/protos/*.proto
    protoc -I ./  --grpc-web_out=import_style=commonjs+dts,mode=grpcwebtext:./dist/js/pb pb/protos/service/*.proto pb/protos/*.proto pkg/lib/pb/model/protos/*.proto
  '';

  postInstall = ''
    mv $out/bin/grpcserver $out/bin/anytypeHelper
    mkdir -p $out/lib
    cp -r dist/js/pb/* $out/lib
    cp -r dist/js/pb/* $out/lib

    mkdir -p $out/lib/json/generated
    cp pkg/lib/bundle/system*.json $out/lib/json/generated
    cp pkg/lib/bundle/internal*.json $out/lib/json/generated

    mkdir -p $out/share
    cp LICENSE.md $out/share
  '';

  # disable tests to save time, as it's mostly built by users, not CI
  doCheck = false;

  meta = {
    description = "Shared library for Anytype clients";
    homepage = "https://anytype.io/";
    license = lib.licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [
      autrimpo
      adda
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
