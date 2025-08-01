{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  lilypond,
}:

python3Packages.buildPythonApplication rec {
  pname = "frescobaldi";
  version = "3.3.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "wbsoft";
    repo = "frescobaldi";
    tag = "v${version}";
    sha256 = "sha256-Q6ruthNcpjLlYydUetkuTECiCIzu055bw40O8BPGq/A=";
  };

  propagatedBuildInputs = with python3Packages; [
    qpageview
    lilypond
    pygame
    python-ly
    sip4
    pyqt5
    poppler-qt5
    pyqtwebengine
  ];

  nativeBuildInputs = [ python3Packages.pyqtwebengine.wrapQtAppsHook ];

  # Needed because source is fetched from git
  preBuild = ''
    make -C i18n
    make -C linux
  '';

  # no tests in shipped with upstream
  doCheck = false;

  dontWrapQtApps = true;
  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
  ];

  meta = with lib; {
    homepage = "https://frescobaldi.org/";
    description = "LilyPond sheet music text editor";
    longDescription = ''
      Powerful text editor with syntax highlighting and automatic completion,
      Music view with advanced Point & Click, Midi player to proof-listen
      LilyPond-generated MIDI files, Midi capturing to enter music,
      Powerful Score Wizard to quickly setup a music score, Snippet Manager
      to store and apply text snippets, templates or scripts, Use multiple
      versions of LilyPond, automatically selects the correct version, Built-in
      LilyPond documentation browser and built-in User Guide, Smart
      layout-control functions like coloring specific objects in the PDF,
      MusicXML import, Modern user iterface with configurable colors,
      fonts and keyboard shortcuts
    '';
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ sepi ];
    platforms = platforms.all;
    broken = stdenv.hostPlatform.isDarwin; # never built on Hydra https://hydra.nixos.org/job/nixpkgs/trunk/frescobaldi.x86_64-darwin
    mainProgram = "frescobaldi";
  };
}
