{
  description = "Application layer for pythoneda-artifact/base";

  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    pythoneda-base = {
      url = "github:pythoneda/base/0.0.1a13";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda-artifact-base = {
      url = "github:pythoneda-artifact/base/0.0.1a1";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
    };
    pythoneda-infrastructure-base = {
      url = "github:pythoneda-infrastructure/base/0.0.1a9";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
    };
    pythoneda-artifact-infrastructure-base = {
      url = "github:pythoneda-artifact-infrastructure/base/0.0.1a1";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
      inputs.pythoneda-artifact-base.follows = "pythoneda-artifact-base";
    };
    pythoneda-application-base = {
      url = "github:pythoneda-application/base/0.0.1a9";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
      inputs.pythoneda-infrastructure-base.follows =
        "pythoneda-infrastructure-base";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        description = "Application layer for pythoneda-artifact/base";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/pythoneda-artifact-application/base";
        maintainers = with pkgs.lib.maintainers; [ ];
        nixpkgsRelease = "nixos-23.05";
        shared = import ./nix/devShells.nix;
        pythoneda-artifact-application-base-for = { version, pythoneda-base
          , pythoneda-artifact-base, pythoneda-infrastructure-base
          , pythoneda-artifact-infrastructure-base, pythoneda-application-base
          , python }:
          let
            pname = "pythoneda-artifact-application-base";
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            src = ./.;
            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip pkgs.jq poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-base
              pythoneda-artifact-base
              pythoneda-infrastructure-base
              pythoneda-application-base
              pythoneda-artifact-infrastructure-base
            ];

            checkInputs = with python.pkgs; [ pytest ];

            pythonImportsCheck = [ "pythonedaartifactinfrastructure" ];

            preBuild = ''
              python -m venv .env
              source .env/bin/activate
              pip install ${pythoneda-base}/dist/pythoneda_base-${pythoneda-base.version}-py3-none-any.whl
              pip install ${pythoneda-artifact-base}/dist/pythoneda_artifact_base-${pythoneda-artifact-base.version}-py3-none-any.whl
              pip install ${pythoneda-infrastructure-base}/dist/pythoneda_infrastructure_base-${pythoneda-infrastructure-base.version}-py3-none-any.whl
              pip install ${pythoneda-artifact-infrastructure-base}/dist/pythoneda_artifact_infrastructure_base-${pythoneda-artifact-infrastructure-base.version}-py3-none-any.whl
              pip install ${pythoneda-application-base}/dist/pythoneda_application_base-${pythoneda-application-base.version}-py3-none-any.whl
              rm -rf .env
            '';

            postInstall = ''
              mkdir $out/dist
              cp dist/${wheelName} $out/dist
              jq ".url = \"$out/dist/${wheelName}\"" $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json > temp.json && mv temp.json $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
        pythoneda-artifact-application-base-0_0_1a1-for = { pythoneda-base
          , pythoneda-artifact-base, pythoneda-infrastructure-base
          , pythoneda-artifact-infrastructure-base, pythoneda-application-base
          , python }:
          pythoneda-artifact-application-base-for {
            version = "0.0.1a1";
            inherit pythoneda-base pythoneda-artifact-base
              pythoneda-infrastructure-base
              pythoneda-artifact-infrastructure-base pythoneda-application-base
              python;
          };
      in rec {
        packages = rec {
          pythoneda-artifact-application-base-0_0_1a1-python38 =
            pythoneda-artifact-application-base-0_0_1a1-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python38;
              pythoneda-artifact-base =
                pythoneda-artifact-base.packages.${system}.pythoneda-artifact-base-latest-python38;
              pythoneda-infrastructure-base =
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base-latest-python38;
              pythoneda-artifact-infrastructure-base =
                pythoneda-artifact-infrastructure-base.packages.${system}.pythoneda-artifact-infrastructure-base-latest-python38;
              pythoneda-application-base =
                pythoneda-application-base.packages.${system}.pythoneda-application-base-latest-python38;
              python = pkgs.python38;
            };
          pythoneda-artifact-application-base-0_0_1a1-python39 =
            pythoneda-artifact-application-base-0_0_1a1-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              pythoneda-artifact-base =
                pythoneda-artifact-base.packages.${system}.pythoneda-artifact-base-latest-python39;
              pythoneda-infrastructure-base =
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base-latest-python39;
              pythoneda-artifact-infrastructure-base =
                pythoneda-artifact-infrastructure-base.packages.${system}.pythoneda-artifact-infrastructure-base-latest-python39;
              pythoneda-application-base =
                pythoneda-application-base.packages.${system}.pythoneda-application-base-latest-python39;
              python = pkgs.python39;
            };
          pythoneda-artifact-application-base-0_0_1a1-python310 =
            pythoneda-artifact-application-base-0_0_1a1-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python310;
              pythoneda-artifact-base =
                pythoneda-artifact-base.packages.${system}.pythoneda-artifact-base-latest-python310;
              pythoneda-infrastructure-base =
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base-latest-python310;
              pythoneda-artifact-infrastructure-base =
                pythoneda-artifact-infrastructure-base.packages.${system}.pythoneda-artifact-infrastructure-base-latest-python310;
              pythoneda-application-base =
                pythoneda-application-base.packages.${system}.pythoneda-application-base-latest-python310;
              python = pkgs.python310;
            };
          pythoneda-artifact-application-base-latest-python38 =
            pythoneda-artifact-application-base-0_0_1a1-python38;
          pythoneda-artifact-application-base-latest-python39 =
            pythoneda-artifact-application-base-0_0_1a1-python39;
          pythoneda-artifact-application-base-latest-python310 =
            pythoneda-artifact-application-base-0_0_1a1-python310;
          pythoneda-artifact-application-base-latest =
            pythoneda-artifact-application-base-latest-python310;
          default = pythoneda-artifact-application-base-latest;
        };
        defaultPackage = packages.default;
        devShells = rec {
          pythoneda-artifact-application-base-0_0_1a1-python38 =
            shared.devShell-for {
              package =
                packages.pythoneda-artifact-application-base-0_0_1a1-python38;
              python = pkgs.python38;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-artifact-application-base-0_0_1a1-python39 =
            shared.devShell-for {
              package =
                packages.pythoneda-artifact-application-base-0_0_1a1-python39;
              python = pkgs.python39;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-artifact-application-base-0_0_1a1-python310 =
            shared.devShell-for {
              package =
                packages.pythoneda-artifact-application-base-0_0_1a1-python310;
              python = pkgs.python310;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-artifact-application-base-latest-python38 =
            pythoneda-artifact-application-base-0_0_1a1-python38;
          pythoneda-artifact-application-base-latest-python39 =
            pythoneda-artifact-application-base-0_0_1a1-python39;
          pythoneda-artifact-application-base-latest-python310 =
            pythoneda-artifact-application-base-0_0_1a1-python310;
          pythoneda-artifact-application-base-latest =
            pythoneda-artifact-application-base-latest-python310;
          default = pythoneda-artifact-application-base-latest;

        };
      });
}