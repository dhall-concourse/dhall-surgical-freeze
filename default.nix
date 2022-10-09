{ mkDerivation, array, base, containers, dhall, filepath, lib, text
}:
mkDerivation {
  pname = "dhall-surgical-freeze";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    array base containers dhall filepath text
  ];
  executableHaskellDepends = [ base ];
  license = lib.licenses.mit;
  mainProgram = "dhall-surgical-freeze";
}
