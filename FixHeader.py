import sys
import struct

def fix_efi(filename):
    try:
        with open(filename, 'r+b') as f:
            # Get PE Header offset
            f.seek(0x3C)
            pe_ptr = struct.unpack('<I', f.read(4))[0]
            
            # 1. Fix Characteristics (offset 18 from PE start)
            # Set to 0x2022 (Executable | Large Address Aware | DLL)
            f.seek(pe_ptr + 18)
            f.write(struct.pack('<H', 0x2022))
            
            # 2. Fix Image Version (offset 44/46 from Optional Header start)
            # Optional Header starts at pe_ptr + 24
            f.seek(pe_ptr + 24 + 44)
            f.write(struct.pack('<H', 2)) # Major 2
            f.write(struct.pack('<H', 1)) # Minor 1
            
            # 3. Fix Subsystem Version (offset 48/50)
            f.seek(pe_ptr + 24 + 48)
            f.write(struct.pack('<H', 2)) # Major 2
            f.write(struct.pack('<H', 1)) # Minor 1
            
        print("Success: Fixed {0} (Characteristics: 0x2022, Version: 2.1)".format(filename))
    except Exception as e:
        print("Error: Could not fix {0} - {1}".format(filename, str(e)))

if __name__ == "__main__":
    if len(sys.argv) > 1:
        fix_efi(sys.argv[1])
    else:
        print("Usage: python FixHeader.py <filename.efi>")