{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  requests,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "kiss-headers";
  version = "2.4.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Ousret";
    repo = "kiss-headers";
    tag = version;
    hash = "sha256-WeAzlC1yT+0nPSuB278z8T0XvPjbre051f/Rva5ujAk=";
  };

  nativeBuildInputs = [ hatchling ];

  propagatedBuildInputs = [ requests ];

  nativeCheckInputs = [ pytestCheckHook ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "--cov=kiss_headers --doctest-modules --cov-report=term-missing -rxXs" "--doctest-modules -rxXs"
  '';

  disabledTestPaths = [
    # Tests require internet access
    "kiss_headers/__init__.py"
    "tests/test_serializer.py"
    "tests/test_with_http_request.py"
  ];

  pythonImportsCheck = [ "kiss_headers" ];

  meta = with lib; {
    description = "Python package for HTTP/1.1 style headers";
    homepage = "https://github.com/Ousret/kiss-headers";
    license = licenses.mit;
    maintainers = [ ];
  };
}
