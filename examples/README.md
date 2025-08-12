# pypostal-flake Examples

This directory contains working examples of how to integrate pypostal-flake into your own Nix projects.

## Examples

### 1. overlay-example/

Demonstrates using the overlay to build packages with pypostal. Note that the overlay method works for building packages but has limitations with devShells in external flakes.

```bash
cd overlay-example
nix build .#address-parser
./result/bin/address-parser "123 Main St"
```

### 2. direct-package-example/

Shows how to use pypostal packages directly without the overlay. This approach gives you more explicit control and is useful when you want to mix packages from different sources.

```bash
cd direct-package-example
nix develop
# Multiple Python versions available:
nix build .#py310-env
nix build .#py311-env
nix build .#py312-env
nix build .#py313-env
```

## Testing the Examples

Each example can be tested by entering its directory and running:

```bash
# Enter the development shell
nix develop

# Test pypostal
python -c "from postal.parser import parse_address; print(parse_address('123 Main St, San Francisco, CA 94102'))"
```

## Adapting for Your System

Remember to change the `system` variable in the flake.nix files to match your platform:
- `"x86_64-linux"` - Linux on x86_64
- `"aarch64-linux"` - Linux on ARM64
- `"x86_64-darwin"` - macOS on Intel
- `"aarch64-darwin"` - macOS on Apple Silicon

## Common Issues

### LIBPOSTAL_DATA_DIR not set

If you see errors about libpostal data, ensure the environment variable is set:

```bash
export LIBPOSTAL_DATA_DIR="${pkgs.libpostalWithData}/share/libpostal"
```

This is automatically set in the example shellHooks.

### Module not found

If Python can't find the postal module, ensure you're either:
1. Using the overlay and referencing `ps.pypostal` in withPackages
2. Using direct package reference and including the pypostal package directly

## Need Help?

Check the main [README](../README.md) for more documentation, or open an issue on GitHub.