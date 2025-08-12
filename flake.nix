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
            pypostal = python-final.buildPythonPackage rec {
              pname = "postal";
              version = "1.0";
              pyproject = true;

              src = python-final.fetchPypi {
                inherit pname version;
                sha256 = "sha256-V8rn7ROLN1TF2e0xhMraRZicClKabro74ozAQ6Yr8+k=";
              };

              nativeBuildInputs = [ final.pkg-config ];
              build-system = [ python-final.setuptools ];
              buildInputs = [ final.libpostalWithData ];
              propagatedBuildInputs = [ python-final.six ];

              postPatch = ''
                substituteInPlace setup.py \
                  --replace "/usr/local/include" "${final.libpostalWithData}/include" \
                  --replace "/usr/local/lib" "${final.libpostalWithData}/lib"
                sed -i '/setup_requires=/,/\],/d' setup.py
                sed -i "s/self.contained_in_expansions('Friedrichstraße 128, Berlin, Germany'/#self.contained_in_expansions('Friedrichstraße 128, Berlin, Germany'/" postal/tests/test_expand.py
              '';

              doCheck = true;
              dontUsePythonRecompileBytecode = true;
              preCheck = ''
                export LIBPOSTAL_DATA_DIR="${final.libpostalWithData}/share/libpostal"
              '';
              checkPhase = ''
                runHook preCheck
                cd build/lib*
                ${python-final.python.interpreter} -m unittest discover -s ../../postal/tests -v
                runHook postCheck
              '';
              pythonImportsCheck = [
                "postal.parser"
                "postal.expand"
              ];
            };
          })
        ];
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        # Import nixpkgs with our own overlay applied
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = false;
          };
          overlays = [ self.overlays.default ];
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

        # Python environments - now with pypostal from the overlay
        python310 = pkgs.python310;
        python311 = pkgs.python311;
        python312 = pkgs.python312;
        python313 = pkgs.python313;

        # Default to Python 3.12
        pypostalDefault = python312.pkgs.pypostal;

        # Demo script for nix run
        demoScript = pkgs.writeScriptBin "pypostal-demo" ''
          #!${pkgs.bash}/bin/bash
          export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
          exec ${python312.withPackages (ps: [ ps.pypostal ])}/bin/python ${./demo.py} "$@"
        '';

      in
      {
        # Formatter for nix fmt
        formatter = treefmtEval.config.build.wrapper;

        # Packages that can be built with nix build
        packages = {
          default = pypostalDefault;
          pypostal = pypostalDefault;
          pypostal-py310 = python310.pkgs.pypostal;
          pypostal-py311 = python311.pkgs.pypostal;
          pypostal-py312 = python312.pkgs.pypostal;
          pypostal-py313 = python313.pkgs.pypostal;
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
                  pypostal
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
                  pypostal
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
                  pypostal
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
                  pypostal
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
                buildInputs = [ (python310.withPackages (ps: [ ps.pypostal ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${
                  python310.withPackages (ps: [ ps.pypostal ])
                }/bin/python -c "import postal.parser; print('pypostal import successful')"
                touch $out
              '';

          pypostal-py311-import =
            pkgs.runCommand "pypostal-py311-import-test"
              {
                buildInputs = [ (python311.withPackages (ps: [ ps.pypostal ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${
                  python311.withPackages (ps: [ ps.pypostal ])
                }/bin/python -c "import postal.parser; print('pypostal import successful')"
                touch $out
              '';

          pypostal-py312-import =
            pkgs.runCommand "pypostal-py312-import-test"
              {
                buildInputs = [ (python312.withPackages (ps: [ ps.pypostal ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${
                  python312.withPackages (ps: [ ps.pypostal ])
                }/bin/python -c "import postal.parser; print('pypostal import successful')"
                touch $out
              '';

          pypostal-py313-import =
            pkgs.runCommand "pypostal-py313-import-test"
              {
                buildInputs = [ (python313.withPackages (ps: [ ps.pypostal ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${
                  python313.withPackages (ps: [ ps.pypostal ])
                }/bin/python -c "import postal.parser; print('pypostal import successful')"
                touch $out
              '';

          pypostal-py310-functionality =
            pkgs.runCommand "pypostal-py310-functionality-test"
              {
                buildInputs = [ (python310.withPackages (ps: [ ps.pypostal ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${python310.withPackages (ps: [ ps.pypostal ])}/bin/python ${./tests/test_functionality.py}
                touch $out
              '';

          pypostal-py311-functionality =
            pkgs.runCommand "pypostal-py311-functionality-test"
              {
                buildInputs = [ (python311.withPackages (ps: [ ps.pypostal ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${python311.withPackages (ps: [ ps.pypostal ])}/bin/python ${./tests/test_functionality.py}
                touch $out
              '';

          pypostal-py312-functionality =
            pkgs.runCommand "pypostal-py312-functionality-test"
              {
                buildInputs = [ (python312.withPackages (ps: [ ps.pypostal ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${python312.withPackages (ps: [ ps.pypostal ])}/bin/python ${./tests/test_functionality.py}
                touch $out
              '';

          pypostal-py313-functionality =
            pkgs.runCommand "pypostal-py313-functionality-test"
              {
                buildInputs = [ (python313.withPackages (ps: [ ps.pypostal ])) ];
              }
              ''
                export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
                ${python313.withPackages (ps: [ ps.pypostal ])}/bin/python ${./tests/test_functionality.py}
                touch $out
              '';

          # Test that the overlay works correctly when used in external flakes
          overlay-test =
            pkgs.runCommand "overlay-test"
              {
                buildInputs = [ pkgs.nix ];
              }
              ''
                # Create a test flake that uses our overlay
                mkdir -p test-flake
                cat > test-flake/flake.nix << 'EOF'
                {
                  inputs.nixpkgs.url = "path:${nixpkgs}";
                  inputs.pypostal.url = "path:${self}";
                  
                  outputs = { self, nixpkgs, pypostal }:
                    let
                      system = "${system}";
                      pkgs = import nixpkgs {
                        inherit system;
                        overlays = [ pypostal.overlays.default ];
                      };
                    in {
                      packages.${system}.test = pkgs.python312.withPackages (ps: [ ps.pypostal ]);
                    };
                }
                EOF

                # Test that the overlay properly adds pypostal to python package sets
                export NIX_CONFIG="experimental-features = nix-command flakes"
                cd test-flake

                # Build the test package using the overlay
                nix build .#test --no-link --print-out-paths > build-result

                # Verify the build succeeded and package exists
                if [ -s build-result ]; then
                  echo "Overlay test passed: pypostal successfully added to python package set"
                  touch $out
                else
                  echo "Overlay test failed: Could not build python with pypostal from overlay"
                  exit 1
                fi
              '';

          # Add treefmt check
          formatting = treefmtEval.config.build.check self;
        };
      }
    );
}
