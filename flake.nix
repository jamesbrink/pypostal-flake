{
  description = "Python bindings for libpostal - Fast international address parsing/normalization";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
    }:
    {
      # Overlays for using in other flakes
      overlays.default = final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            pypostal = python-final.callPackage ./pkgs/pypostal.nix {
              inherit (final) pkg-config;
              libpostal = final.libpostalWithData;
            };
          })
        ];
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = false;
          };
        };

        # Configure treefmt
        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs = {
            nixfmt-rfc-style.enable = true;
            prettier = {
              enable = true;
              excludes = [ "*.md" ];
            };
          };
        };

        # Function to build pypostal for a specific Python version
        mkPypostal =
          python:
          python.pkgs.callPackage ./pkgs/pypostal.nix {
            inherit (pkgs) pkg-config;
            libpostal = pkgs.libpostalWithData;
          };

        # Python environments
        python310 = pkgs.python310;
        python311 = pkgs.python311;
        python312 = pkgs.python312;
        python313 = pkgs.python313;

        # Pypostal packages for different Python versions
        pypostal310 = mkPypostal python310;
        pypostal311 = mkPypostal python311;
        pypostal312 = mkPypostal python312;
        pypostal313 = mkPypostal python313;

        # Default to Python 3.12
        pypostalDefault = pypostal312;

        # Demo script for nix run
        demoScript = pkgs.writeScriptBin "pypostal-demo" ''
          #!${pkgs.bash}/bin/bash
          export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
          exec ${python312.withPackages (ps: [ pypostal312 ])}/bin/python ${./demo.py} "$@"
        '';

      in
      {
        # Formatter for nix fmt
        formatter = treefmtEval.config.build.wrapper;

        # Packages that can be built with nix build
        packages = {
          default = pypostalDefault;
          pypostal = pypostalDefault;
          pypostal-py310 = pypostal310;
          pypostal-py311 = pypostal311;
          pypostal-py312 = pypostal312;
          pypostal-py313 = pypostal313;
          demo = demoScript;
        };

        # Development shells
        devShells = {
          default = self.devShells.${system}.py312;

          py310 = pkgs.mkShell {
            name = "pypostal-dev-py310";
            buildInputs = with pkgs; [
              (python310.withPackages (
                ps: with ps; [
                  pypostal310
                  pytest
                  build
                  setuptools
                  wheel
                ]
              ))
              pkg-config
              libpostalWithData
            ];

            shellHook = ''
              export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
              echo "pypostal development environment (Python 3.10)"
              echo "libpostal data directory: $LIBPOSTAL_DATA_DIR"
              python --version
            '';
          };

          py311 = pkgs.mkShell {
            name = "pypostal-dev-py311";
            buildInputs = with pkgs; [
              (python311.withPackages (
                ps: with ps; [
                  pypostal311
                  pytest
                  build
                  setuptools
                  wheel
                ]
              ))
              pkg-config
              libpostalWithData
            ];

            shellHook = ''
              export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
              echo "pypostal development environment (Python 3.11)"
              echo "libpostal data directory: $LIBPOSTAL_DATA_DIR"
              python --version
            '';
          };

          py312 = pkgs.mkShell {
            name = "pypostal-dev-py312";
            buildInputs = with pkgs; [
              (python312.withPackages (
                ps: with ps; [
                  pypostal312
                  pytest
                  build
                  setuptools
                  wheel
                ]
              ))
              pkg-config
              libpostalWithData
            ];

            shellHook = ''
              export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
              echo "pypostal development environment (Python 3.12)"
              echo "libpostal data directory: $LIBPOSTAL_DATA_DIR"
              python --version
            '';
          };

          py313 = pkgs.mkShell {
            name = "pypostal-dev-py313";
            buildInputs = with pkgs; [
              (python313.withPackages (
                ps: with ps; [
                  pypostal313
                  pytest
                  build
                  setuptools
                  wheel
                ]
              ))
              pkg-config
              libpostalWithData
            ];

            shellHook = ''
              export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
              echo "pypostal development environment (Python 3.13)"
              echo "libpostal data directory: $LIBPOSTAL_DATA_DIR"
              python --version
            '';
          };
        };

        # Apps that can be run with nix run
        apps = {
          default = self.apps.${system}.demo;
          demo = {
            type = "app";
            program = "${demoScript}/bin/pypostal-demo";
          };
        };

        # Checks that run with nix flake check
        checks = {
          pypostal-py310-import =
            pkgs.runCommand "pypostal-py310-import-test"
              {
                buildInputs = [ (python310.withPackages (ps: [ pypostal310 ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${
                  python310.withPackages (ps: [ pypostal310 ])
                }/bin/python -c "import postal.parser; print('pypostal import successful')"
                touch $out
              '';

          pypostal-py311-import =
            pkgs.runCommand "pypostal-py311-import-test"
              {
                buildInputs = [ (python311.withPackages (ps: [ pypostal311 ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${
                  python311.withPackages (ps: [ pypostal311 ])
                }/bin/python -c "import postal.parser; print('pypostal import successful')"
                touch $out
              '';

          pypostal-py312-import =
            pkgs.runCommand "pypostal-py312-import-test"
              {
                buildInputs = [ (python312.withPackages (ps: [ pypostal312 ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${
                  python312.withPackages (ps: [ pypostal312 ])
                }/bin/python -c "import postal.parser; print('pypostal import successful')"
                touch $out
              '';

          pypostal-py313-import =
            pkgs.runCommand "pypostal-py313-import-test"
              {
                buildInputs = [ (python313.withPackages (ps: [ pypostal313 ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${
                  python313.withPackages (ps: [ pypostal313 ])
                }/bin/python -c "import postal.parser; print('pypostal import successful')"
                touch $out
              '';

          pypostal-py310-functionality =
            pkgs.runCommand "pypostal-py310-functionality-test"
              {
                buildInputs = [ (python310.withPackages (ps: [ pypostal310 ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${python310.withPackages (ps: [ pypostal310 ])}/bin/python ${./tests/test_functionality.py}
                touch $out
              '';

          pypostal-py311-functionality =
            pkgs.runCommand "pypostal-py311-functionality-test"
              {
                buildInputs = [ (python311.withPackages (ps: [ pypostal311 ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${python311.withPackages (ps: [ pypostal311 ])}/bin/python ${./tests/test_functionality.py}
                touch $out
              '';

          pypostal-py312-functionality =
            pkgs.runCommand "pypostal-py312-functionality-test"
              {
                buildInputs = [ (python312.withPackages (ps: [ pypostal312 ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${python312.withPackages (ps: [ pypostal312 ])}/bin/python ${./tests/test_functionality.py}
                touch $out
              '';

          pypostal-py313-functionality =
            pkgs.runCommand "pypostal-py313-functionality-test"
              {
                buildInputs = [ (python313.withPackages (ps: [ pypostal313 ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${python313.withPackages (ps: [ pypostal313 ])}/bin/python ${./tests/test_functionality.py}
                touch $out
              '';

          # Add treefmt check
          formatting = treefmtEval.config.build.check self;
        };
      }
    );
}
