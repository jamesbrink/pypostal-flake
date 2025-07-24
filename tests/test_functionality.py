#!/usr/bin/env python3
"""Basic functionality tests for pypostal."""

import sys
import os

def test_parser():
    """Test address parsing functionality."""
    from postal.parser import parse_address
    
    # Test US address
    address = "1600 Pennsylvania Avenue NW, Washington, DC 20500"
    parsed = parse_address(address)
    
    # Verify we got results
    assert parsed, "Failed to parse address"
    assert len(parsed) > 0, "No parse results returned"
    
    # Check for expected components
    components = dict(parsed)
    # Note: libpostal parsing can vary, so we check for common components
    assert any(comp[1] == 'house_number' for comp in parsed), "Missing house_number in parsed results"
    
    # Test international address
    intl_address = "4 Rue de la Paix, 75002 Paris, France"
    intl_parsed = parse_address(intl_address)
    assert intl_parsed, "Failed to parse international address"
    
    print("✓ Parser tests passed")
    return True

def test_expand():
    """Test address expansion functionality."""
    from postal.expand import expand_address
    
    # Test abbreviation expansion
    address = "123 Main St Apt 4"
    expansions = expand_address(address)
    
    assert expansions, "Failed to expand address"
    assert len(expansions) > 0, "No expansions returned"
    
    # Should expand "St" to "Street" and "Apt" to "Apartment"
    found_street = any('street' in exp.lower() for exp in expansions)
    found_apartment = any('apartment' in exp.lower() for exp in expansions)
    
    assert found_street, "Failed to expand 'St' to 'Street'"
    assert found_apartment, "Failed to expand 'Apt' to 'Apartment'"
    
    print("✓ Expansion tests passed")
    return True

def test_normalize():
    """Test address normalization."""
    from postal.parser import parse_address
    
    # Different representations of similar addresses
    addresses = [
        "123 MAIN STREET",
        "123 main st",
        "123 Main St.",
    ]
    
    parsed_results = []
    for addr in addresses:
        parsed = parse_address(addr)
        parsed_results.append(parsed)
    
    # All should parse successfully
    assert all(parsed_results), "Failed to parse normalized addresses"
    
    print("✓ Normalization tests passed")
    return True

def test_dedupe():
    """Test deduplication capability."""
    try:
        from postal.dedupe import dedupe
        
        # Test similar addresses
        addresses = [
            "123 Main Street Apt 4",
            "123 Main St. #4",
            "456 Oak Avenue"
        ]
        
        # Try to dedupe - this might not be available in all builds
        deduped = dedupe(addresses)
        assert deduped is not None, "Failed to dedupe addresses"
        
        print("✓ Dedupe tests passed")
        return True
    except ImportError:
        # dedupe module might not be available in all pypostal builds
        print("✓ Dedupe tests skipped (module not available)")
        return True

def main():
    """Run all tests."""
    print("Running pypostal functionality tests...")
    print(f"Python version: {sys.version}")
    print(f"LIBPOSTAL_DATA_DIR: {os.environ.get('LIBPOSTAL_DATA_DIR', 'NOT SET')}")
    print()
    
    tests = [
        test_parser,
        test_expand,
        test_normalize,
        test_dedupe,
    ]
    
    failed = 0
    for test in tests:
        try:
            test()
        except Exception as e:
            print(f"✗ {test.__name__} failed: {e}")
            failed += 1
    
    print()
    if failed == 0:
        print("All tests passed!")
        sys.exit(0)
    else:
        print(f"{failed} tests failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()