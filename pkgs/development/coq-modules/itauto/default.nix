{
  lib,
  callPackage,
  mkCoqDerivation,
  coq,
  stdlib,
  version ? null,
}:

(mkCoqDerivation {
  pname = "itauto";
  owner = "fbesson";
  domain = "gitlab.inria.fr";

  release."8.20.0".sha256 = "sha256-LYKGbI3O6yw6CiTJNUGL11PT4q4o+gJK1kQgKQL0/Hk=";
  release."8.19.0".sha256 = "sha256-xKWCF4dYvvlJUVGCZcR2RLCG55vlGzu2GN30MeRvVD4=";
  release."8.18.0".sha256 = "sha256-4mDDnKTeYrf27uRMkydQxO7j2tfgTFXOREW474d40eo=";
  release."8.17.0".sha256 = "sha256-fgdnKchNT1Hyrq14gU8KWYnlSfg3qlsSw5A4+RoA26w=";
  release."8.16.0".sha256 = "sha256-4zAUYGlw/pBcLPv2GroIduIlvbfi1+Vy+TdY8KLCqO4=";
  release."8.15.0".sha256 = "sha256:10qpv4nx1p0wm9sas47yzsg9z22dhvizszfa21yff08a8fr0igya";
  release."8.14.0".sha256 = "sha256:1k6pqhv4dwpkwg81f2rlfg40wh070ks1gy9r0ravm2zhsbxqcfc9";
  release."8.13+no".sha256 = "sha256-gXoxtLcHPoyjJkt7WqvzfCMCQlh6kL2KtCGe3N6RC/A=";
  inherit version;
  defaultVersion =
    let
      case = case: out: { inherit case out; };
    in
    with lib.versions;
    lib.switch coq.coq-version [
      (case (isEq "8.20") "8.20.0")
      (case (isEq "8.19") "8.19.0")
      (case (isEq "8.18") "8.18.0")
      (case (isEq "8.17") "8.17.0")
      (case (isEq "8.16") "8.16.0")
      (case (isEq "8.15") "8.15.0")
      (case (isEq "8.14") "8.14.0")
      (case (isEq "8.13") "8.13+no")
    ] null;

  mlPlugin = true;
  nativeBuildInputs = (with coq.ocamlPackages; [ ocamlbuild ]);
  enableParallelBuilding = false;

  passthru.tests.suite = callPackage ./test.nix { };

  propagatedBuildInputs = [ stdlib ];

  meta = with lib; {
    description = "Reflexive SAT solver parameterised by a leaf tactic and Nelson-Oppen support";
    maintainers = with maintainers; [ siraben ];
    license = licenses.gpl3Plus;
  };
}).overrideAttrs
  (
    o:
    lib.optionalAttrs (o.version == "dev" || lib.versionAtLeast o.version "8.16") {
      propagatedBuildInputs = o.propagatedBuildInputs ++ [ coq.ocamlPackages.findlib ];
    }
    // lib.optionalAttrs (o.version == "dev" || lib.versionAtLeast o.version "8.18") {
      nativeBuildInputs = with coq.ocamlPackages; [
        ocaml
        findlib
        dune_3
      ];
    }
  )
