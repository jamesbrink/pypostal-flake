{
  description = "Example of using pypostal-flake with overlay";

  inputs = {
    pypostal.url = "path:../.."; # Use local path for testing, change to "github:jamesbrink/pypostal-flake" for production
    nixpkgs.follows = "pypostal/nixpkgs"; # Use the same nixpkgs as pypostal-flake
  };

  outputs =
    {
      self,
      nixpkgs,
      pypostal,
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

      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ pypostal.overlays.default ];
        }
      );

    in
    {
      # Example applications using pypostal via overlay
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          # This works! The overlay makes pypostal available in packages
          address-parser = pkgs.writeScriptBin "address-parser" ''
            #!${pkgs.python312.withPackages (ps: [ ps.pypostal ])}/bin/python

            import sys
            from postal.parser import parse_address

            if len(sys.argv) > 1:
                address = " ".join(sys.argv[1:])
                parsed = parse_address(address)
                print(f"Parsing: {address}")
                for component, label in parsed:
                    print(f"  {label}: {component}")
            else:
                print("Usage: address-parser <address>")
          '';

          # Python environment with pypostal
          python-env = pkgs.python312.withPackages (ps: [
            ps.pypostal
            ps.ipython
            ps.requests
          ]);
        }
      );
    };
}
