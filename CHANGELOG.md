# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2024-08-12

### Added
- Overlay functionality for using pypostal in external flakes
- Example flakes demonstrating both overlay and direct package reference methods
- Claude AI code review workflow for automated PR reviews
- Sticky comments support in Claude reviews
- Comprehensive documentation for both usage methods
- Better error messages and troubleshooting guide

### Fixed
- Overlay implementation now works correctly across flake boundaries
- CI/CD sandbox environment compatibility issues
- Cross-platform CI/CD support (dynamic system detection)
- libpostal vs libpostalWithData inconsistency resolved
- Python 3.10 + ipython compatibility documented

### Changed
- Improved README with clear usage examples for both methods
- Enhanced CI/CD pipeline with integration tests
- Better package organization using overlays

## [0.1.0] - 2024-07-24

### Added
- Initial release of pypostal-flake
- Basic pypostal packaging for Nix
- Support for Python 3.10, 3.11, 3.12, and 3.13
- Development shells for each Python version
- Demo application with address parsing examples
- Comprehensive test suite
- CI/CD pipeline with GitHub Actions
- Automatic dependency updates workflow
- Upstream version checking

### Installation
```bash
# Using nix profile
nix profile install github:jamesbrink/pypostal-flake/v0.1.0#pypostal

# In a flake
pypostal.url = "github:jamesbrink/pypostal-flake/v0.1.0";
```

### Supported Python Versions
- Python 3.10
- Python 3.11
- Python 3.12
- Python 3.13

[0.2.0]: https://github.com/jamesbrink/pypostal-flake/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/jamesbrink/pypostal-flake/releases/tag/v0.1.0