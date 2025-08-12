# pypostal-flake

A Nix flake providing [pypostal](https://github.com/openvenues/pypostal) - Python bindings for [libpostal](https://github.com/openvenues/libpostal), a fast statistical parser/normalizer for international street addresses.

[![CI/CD](https://github.com/jamesbrink/pypostal-flake/actions/workflows/ci.yml/badge.svg)](https://github.com/jamesbrink/pypostal-flake/actions/workflows/ci.yml)
[![Built with Nix](https://img.shields.io/badge/Built_With-Nix-5277C3.svg?logo=nixos&labelColor=73C3D5)](https://nixos.org)
[![Python Versions](https://img.shields.io/badge/Python-3.10%20%7C%203.11%20%7C%203.12%20%7C%203.13-blue.svg)](https://www.python.org/)

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Installation](#installation)
  - [Install to User Profile](#install-to-user-profile)
  - [NixOS Configuration](#nixos-configuration)
  - [Home Manager](#home-manager)
- [Usage in Your Project](#usage-in-your-project)
- [Development](#development)
- [Package Outputs](#package-outputs)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Features

- Pre-built packages for Python 3.10, 3.11, 3.12, and 3.13
- Automatic handling of libpostal data files via `libpostalWithData`
- Development shells with all dependencies
- Overlay support for integration into other flakes
- Comprehensive test suite

## About libpostal Data

This flake uses the `libpostalWithData` package from nixpkgs, which includes the large pre-trained statistical models needed for address parsing. The data directory (approximately 2GB) is automatically configured via the `LIBPOSTAL_DATA_DIR` environment variable in all shells and scripts.

## Quick Start

### Try it out instantly

```bash
# Run the interactive demo
nix run github:jamesbrink/pypostal-flake

# Parse a specific address
nix run github:jamesbrink/pypostal-flake -- "123 Main St, San Francisco, CA 94102"
```

### Use in a Nix shell

```bash
# Python 3.12 (default)
nix develop github:jamesbrink/pypostal-flake

# Python 3.10
nix develop github:jamesbrink/pypostal-flake#py310

# Python 3.11
nix develop github:jamesbrink/pypostal-flake#py311

# Python 3.13
nix develop github:jamesbrink/pypostal-flake#py313
```

## Installation

### Install to User Profile

```bash
# Install default (Python 3.12)
nix profile add github:jamesbrink/pypostal-flake#pypostal

# Install specific Python version
nix profile add github:jamesbrink/pypostal-flake#pypostal-py311

# Note: You'll need to set LIBPOSTAL_DATA_DIR environment variable
export LIBPOSTAL_DATA_DIR=$(nix eval --raw nixpkgs#libpostalWithData)/share/libpostal
```

### NixOS Configuration

Add to your `configuration.nix`:

```nix
{
  inputs.pypostal.url = "github:jamesbrink/pypostal-flake";
  
  # In your system configuration
  environment.systemPackages = with pkgs; [
    inputs.pypostal.packages.${system}.pypostal
    # Or for a specific Python version
    # inputs.pypostal.packages.${system}.pypostal-py311
  ];
  
  # Set the environment variable system-wide
  environment.variables = {
    LIBPOSTAL_DATA_DIR = "${pkgs.libpostalWithData}/share/libpostal";
  };
}
```

### Home Manager

Add to your Home Manager configuration:

```nix
{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.pypostal.packages.${pkgs.system}.pypostal
  ];
  
  home.sessionVariables = {
    LIBPOSTAL_DATA_DIR = "${pkgs.libpostalWithData}/share/libpostal";
  };
}
```

## Usage in Your Project

There are two main ways to use pypostal in your Nix project:

### Method 1: Direct Package Reference (Recommended)

This method gives you direct control and works reliably for all use cases including development shells:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pypostal-flake.url = "github:jamesbrink/pypostal-flake";
  };

  outputs = { self, nixpkgs, pypostal-flake }:
    let
      system = "x86_64-linux"; # or your system
      pkgs = import nixpkgs { inherit system; };
      
      # Get the specific pypostal package for your Python version
      pypostal = pypostal-flake.packages.${system}.pypostal-py312;
      
      pythonEnv = pkgs.python312.withPackages (ps: [
        # Add pypostal directly (not from ps)
        pypostal
        # your other Python packages from ps
        ps.requests
        ps.numpy
      ]);
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pythonEnv
          pkgs.libpostalWithData
        ];
        
        shellHook = ''
          export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
        '';
      };
    };
}
```

### Method 2: Using the Overlay

**Note:** The overlay method has limitations with devShells when used from external flakes. It works best for building packages.

The overlay adds `pypostal` to all Python package sets:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pypostal-flake.url = "github:jamesbrink/pypostal-flake";
  };

  outputs = { self, nixpkgs, pypostal-flake }:
    let
      system = "x86_64-linux"; # or your system
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ pypostal-flake.overlays.default ];
      };
    in
    {
      # Works for packages but not reliably for devShells
      packages.${system} = {
        my-app = pkgs.writeScriptBin "my-app" ''
          #!${pkgs.python312.withPackages (ps: [ ps.pypostal ])}/bin/python
          from postal.parser import parse_address
          # your application code here
        '';
        
        # Python environment package
        python-env = pkgs.python312.withPackages (ps: [ ps.pypostal ]);
      };
    };
}
```

### Package Naming

The flake provides the following package outputs:

- `pypostal` or `default` - Default package (Python 3.12)
- `pypostal-py310` - Python 3.10 version
- `pypostal-py311` - Python 3.11 version  
- `pypostal-py312` - Python 3.12 version
- `pypostal-py313` - Python 3.13 version

### Using Multiple Python Versions

With direct package references:

```nix
packages = {
  myapp-py310 = pkgs.python310.withPackages (ps: [
    pypostal-flake.packages.${system}.pypostal-py310
  ]);
  myapp-py311 = pkgs.python311.withPackages (ps: [
    pypostal-flake.packages.${system}.pypostal-py311
  ]);
  myapp-py312 = pkgs.python312.withPackages (ps: [
    pypostal-flake.packages.${system}.pypostal-py312
  ]);
  myapp-py313 = pkgs.python313.withPackages (ps: [
    pypostal-flake.packages.${system}.pypostal-py313
  ]);
};
```

With the overlay (for packages only, not devShells):

```nix
# After applying the overlay to pkgs
packages = {
  myapp-py310 = pkgs.python310.withPackages (ps: [ ps.pypostal ]);
  myapp-py311 = pkgs.python311.withPackages (ps: [ ps.pypostal ]);
  myapp-py312 = pkgs.python312.withPackages (ps: [ ps.pypostal ]);
  myapp-py313 = pkgs.python313.withPackages (ps: [ ps.pypostal ]);
};
```

## Environment Variables

The `LIBPOSTAL_DATA_DIR` environment variable must be set to the libpostal data directory. This is automatically configured in the development shells and demo script.

```bash
export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
```

## Example Usage

```python
from postal.parser import parse_address

# Parse an address
parsed = parse_address("The White House, 1600 Pennsylvania Avenue NW, Washington, DC 20500")
print(parsed)
# Output: [('the white house', 'house'), ('1600', 'house_number'), 
#          ('pennsylvania avenue nw', 'road'), ('washington', 'city'),
#          ('dc', 'state'), ('20500', 'postcode')]

# Expand an address (normalize abbreviations)
from postal.expand import expand_address
expansions = expand_address("123 Main St Apt 4")
print(expansions)
# Output: ['123 main street apartment 4', '123 main st apartment 4', ...]
```

## Development

### Building locally

```bash
# Clone the repository
git clone https://github.com/jamesbrink/pypostal-flake
cd pypostal-flake

# Enter development shell
nix develop

# Run tests
nix flake check

# Build packages
nix build .#pypostal-py310
nix build .#pypostal-py311
nix build .#pypostal-py312
nix build .#pypostal-py313
```

### Running tests

```bash
# Run all checks
nix flake check

# Run specific tests
nix build .#checks.x86_64-linux.pypostal-py312-import
nix build .#checks.x86_64-linux.pypostal-py312-functionality
```

## Package Outputs

- `packages.default` - Default pypostal package (Python 3.12)
- `packages.pypostal` - Same as default
- `packages.pypostal-py310` - Python 3.10 version
- `packages.pypostal-py311` - Python 3.11 version
- `packages.pypostal-py312` - Python 3.12 version
- `packages.pypostal-py313` - Python 3.13 version
- `packages.demo` - Demo script

## Overlay

The overlay adds `pypostal` to all Python package sets:

```nix
overlays = [ pypostal.overlays.default ];

# Then use with any Python version
python310.withPackages (ps: [ ps.pypostal ])
python311.withPackages (ps: [ ps.pypostal ])
python312.withPackages (ps: [ ps.pypostal ])
python313.withPackages (ps: [ ps.pypostal ])
```

## Troubleshooting

### "No module named 'postal'" when using the overlay

The overlay method has limitations when used from external flakes for devShells. If you encounter this error:

1. **Use the direct package reference method instead** (Method 1) for development shells
2. The overlay works for building packages but not reliably for devShells in external flakes
3. This is a known Nix limitation with how overlays compose across flake boundaries

### Import Error: "Could not find libpostal"

This error means the libpostal data directory is not set. Ensure `LIBPOSTAL_DATA_DIR` is set correctly:

```bash
export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
```

Also make sure `libpostalWithData` is included in your `buildInputs`.

### Finding available package versions

To see all available pypostal packages:

```bash
nix flake show github:jamesbrink/pypostal-flake
```

### Building from source fails

Make sure you have the required build dependencies:

```nix
buildInputs = [ pkg-config libpostalWithData ];
```

### Overlay not working in your flake

If the overlay doesn't work for devShells, use the direct package reference method (Method 1). The overlay method is best suited for building packages, not development shells.

## License

This flake is released under the MIT License. See [LICENSE](LICENSE) for details.

pypostal itself is also MIT licensed.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- [libpostal](https://github.com/openvenues/libpostal) - The underlying address parsing library
- [pypostal](https://github.com/openvenues/pypostal) - Python bindings for libpostal