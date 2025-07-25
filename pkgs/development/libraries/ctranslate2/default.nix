{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  llvmPackages, # openmp
  withMkl ? false,
  mkl,
  withCUDA ? false,
  withCuDNN ? false,
  cudaPackages,
  # Enabling both withOneDNN and withOpenblas is broken
  # https://github.com/OpenNMT/CTranslate2/issues/1294
  withOneDNN ? false,
  oneDNN,
  withOpenblas ? true,
  openblas,
  withRuy ? true,

  # passthru tests
  libretranslate,
  wyoming-faster-whisper,
}:

let
  cmakeBool = b: if b then "ON" else "OFF";
in
stdenv.mkDerivation rec {
  pname = "ctranslate2";
  version = "4.6.0";

  src = fetchFromGitHub {
    owner = "OpenNMT";
    repo = "CTranslate2";
    rev = "v${version}";
    hash = "sha256-EM2kunqtxo0BTIzrEomfaRsdav7sx6QEOhjDtjjSoYY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
  ]
  ++ lib.optionals withCUDA [
    cudaPackages.cuda_nvcc
  ];

  cmakeFlags = [
    # https://opennmt.net/CTranslate2/installation.html#build-options
    # https://github.com/OpenNMT/CTranslate2/blob/54810350e662ebdb01ecbf8e4a746f02aeff1dd7/python/tools/prepare_build_environment_linux.sh#L53
    # https://github.com/OpenNMT/CTranslate2/blob/59d223abcc7e636c1c2956e62482bc3299cc7766/python/tools/prepare_build_environment_macos.sh#L12
    "-DOPENMP_RUNTIME=COMP"
    "-DWITH_CUDA=${cmakeBool withCUDA}"
    "-DWITH_CUDNN=${cmakeBool withCuDNN}"
    "-DWITH_DNNL=${cmakeBool withOneDNN}"
    "-DWITH_OPENBLAS=${cmakeBool withOpenblas}"
    "-DWITH_RUY=${cmakeBool withRuy}"
    "-DWITH_MKL=${cmakeBool withMkl}"
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin "-DWITH_ACCELERATE=ON";

  buildInputs =
    lib.optionals withMkl [
      mkl
    ]
    ++ lib.optionals withCUDA [
      cudaPackages.cuda_cccl # <nv/target> required by the fp16 headers in cudart
      cudaPackages.cuda_cudart
      cudaPackages.libcublas
      cudaPackages.libcurand
    ]
    ++ lib.optionals (withCUDA && withCuDNN) [
      cudaPackages.cudnn
    ]
    ++ lib.optionals withOneDNN [
      oneDNN
    ]
    ++ lib.optionals withOpenblas [
      openblas
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      llvmPackages.openmp
    ];

  passthru.tests = {
    inherit
      libretranslate
      wyoming-faster-whisper
      ;
  };

  meta = with lib; {
    description = "Fast inference engine for Transformer models";
    mainProgram = "ct2-translator";
    homepage = "https://github.com/OpenNMT/CTranslate2";
    changelog = "https://github.com/OpenNMT/CTranslate2/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [
      hexa
      misuzu
    ];
    broken = (cudaPackages.cudaOlder "11.4") || !(withCuDNN -> withCUDA);
  };
}
