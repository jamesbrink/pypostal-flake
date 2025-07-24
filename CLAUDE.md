# pypostal-flake Project Context

## Overview

This is a Nix flake that packages pypostal (Python bindings for libpostal) for use in Nix environments. The flake provides pre-built packages for Python 3.10, 3.11, 3.12, and 3.13.

## Key Technical Details

### Package Structure
- Main flake at `flake.nix` provides packages, overlays, devShells, and checks
- Package definition at `pkgs/pypostal.nix` handles the Python package build
- Uses `libpostalWithData` from nixpkgs which includes the ~2GB pre-trained models

### Python Versions
- Supports Python 3.10, 3.11, 3.12, and 3.13
- Default is Python 3.12
- Each version has its own package output and development shell

### Testing
- Runs upstream pypostal tests during build
- One test (German address expansion) is patched as it appears to be locale/data specific
- Additional import checks verify the package works after installation
- Comprehensive functionality tests in `tests/test_functionality.py`

### Environment Variables
- `LIBPOSTAL_DATA_DIR` must be set to the libpostal data directory
- This is automatically configured in all shells and scripts

## Common Tasks

### Building packages
```bash
nix build .#pypostal-py310
nix build .#pypostal-py311
nix build .#pypostal-py312
nix build .#pypostal-py313
```

### Running tests
```bash
nix flake check
```

### Entering development shell
```bash
nix develop .#py312  # or py310, py311, py313
```

### Running the demo
```bash
nix run .#demo
```

## Maintenance Notes

### Updating pypostal version
1. Update version and sha256 in `pkgs/pypostal.nix`
2. Test all Python versions
3. Ensure upstream tests still pass

### Adding new Python version
1. Add pythonXXX variable in flake.nix
2. Create pypostalXXX package
3. Add devShell entry
4. Add checks for import and functionality
5. Update README.md

### Known Issues
- Some libpostal expansions may vary based on the data version
- The German address test in upstream is commented out due to inconsistent results

## Project Standards
- All Nix files should be formatted with nixfmt-rfc-style
- Maintain support for all active Python versions
- Keep README examples up to date
- Run full test suite before releases