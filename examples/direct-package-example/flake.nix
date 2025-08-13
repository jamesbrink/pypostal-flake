{
  description = "Example of using pypostal-flake with direct package reference";

  inputs = {
    pypostal-flake.url = "path:../.."; # Use local path for testing, change to "github:jamesbrink/pypostal-flake" for production
    nixpkgs.follows = "pypostal-flake/nixpkgs"; # Use the same nixpkgs as pypostal-flake
  };

  outputs =
    {
      self,
      nixpkgs,
      pypostal-flake,
    }:
    let
      # Support multiple systems
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      # Development shell
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};

          # Get pypostal package directly from the flake
          pypostal = pypostal-flake.packages.${system}.pypostal-py312;

          # Create Python environment with pypostal
          pythonEnv = pkgs.python312.withPackages (ps: [
            # Add pypostal directly (not from ps since we're not using overlay)
            pypostal

            # Other packages from the standard Python package set
            ps.ipython
            ps.requests
            ps.pandas
          ]);
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              pythonEnv
              pkgs.libpostalWithData # Required for data files
            ];

            shellHook = ''
              echo "pypostal direct package example environment"
              echo "Python version: $(python --version)"
              export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
              echo "LIBPOSTAL_DATA_DIR set to: $LIBPOSTAL_DATA_DIR"
              echo ""
              echo "Try running: python -c 'from postal.parser import parse_address; print(parse_address(\"123 Main St, San Francisco, CA 94102\"))'"
            '';
          };
        }
      );

      # Example with multiple Python versions
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          # Python 3.10 environment
          py310-env = pkgs.python310.withPackages (ps: [
            pypostal-flake.packages.${system}.pypostal-py310
            # Note: ipython is not included here due to compatibility issues
            # with Python 3.10 in the current nixpkgs version. If you need
            # an interactive REPL, use the standard python interpreter.
          ]);

          # Python 3.11 environment
          py311-env = pkgs.python311.withPackages (ps: [
            pypostal-flake.packages.${system}.pypostal-py311
            ps.ipython
          ]);

          # Python 3.12 environment
          py312-env = pkgs.python312.withPackages (ps: [
            pypostal-flake.packages.${system}.pypostal-py312
            ps.ipython
          ]);

          # Python 3.13 environment
          py313-env = pkgs.python313.withPackages (ps: [
            pypostal-flake.packages.${system}.pypostal-py313
            ps.ipython
          ]);
        }
      );
    };
}
