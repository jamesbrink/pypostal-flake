#!/usr/bin/env python3
"""Demo script for pypostal - demonstrates address parsing and expansion."""

import sys
import os
from postal.parser import parse_address
from postal.expand import expand_address

def print_header(text):
    """Print a formatted header."""
    print("\n" + "=" * 60)
    print(text)
    print("=" * 60)

def demo_parser(address):
    """Demonstrate address parsing."""
    print_header("Address Parser")
    print(f"Input: {address}")
    print("\nParsed components:")
    
    parsed = parse_address(address)
    for component, label in parsed:
        print(f"  {label:20} : {component}")

def demo_expansion(address):
    """Demonstrate address expansion."""
    print_header("Address Expansion")
    print(f"Input: {address}")
    print("\nExpansions:")
    
    expansions = expand_address(address)
    for i, expansion in enumerate(expansions[:10], 1):  # Show first 10
        print(f"  {i:2}. {expansion}")
    
    if len(expansions) > 10:
        print(f"  ... and {len(expansions) - 10} more")

def demo_similar_addresses(addr1, addr2):
    """Demonstrate parsing of similar addresses."""
    print_header("Similar Address Comparison")
    print(f"Address 1: {addr1}")
    print(f"Address 2: {addr2}")
    
    parsed1 = parse_address(addr1)
    parsed2 = parse_address(addr2)
    
    print("\nAddress 1 parsed:")
    for component, label in parsed1:
        print(f"  {label:20} : {component}")
    
    print("\nAddress 2 parsed:")
    for component, label in parsed2:
        print(f"  {label:20} : {component}")

def main():
    """Main demo function."""
    print("pypostal Demo - Python bindings for libpostal")
    print(f"Python version: {sys.version.split()[0]}")
    print(f"LIBPOSTAL_DATA_DIR: {os.environ.get('LIBPOSTAL_DATA_DIR', 'NOT SET')}")
    
    # Get address from command line or use default
    if len(sys.argv) > 1:
        address = " ".join(sys.argv[1:])
    else:
        address = "123 Main St Apt 4, San Francisco, CA 94102"
    
    # Demo parsing
    demo_parser(address)
    
    # Demo expansion
    demo_expansion(address)
    
    # Demo similar address comparison
    if len(sys.argv) <= 1:  # Only show for default demo
        demo_similar_addresses(
            "123 Main Street Apartment 4, San Francisco, CA 94102",
            "123 Main St. Apt #4, San Francisco, California 94102"
        )
    
    print("\n✨ Demo complete!")
    print("\nTry it with your own address:")
    print("  nix run github:jamesbrink/pypostal-flake -- \"Your Address Here\"")

if __name__ == "__main__":
    main()