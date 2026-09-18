def crc32_mpeg2(data, prev_crc=0xffffffff):
    """
    Calculate CRC-32/MPEG-2
    Polynomial: 0x04C11DB7
    Initial value: 0xffffffff
    XOR out: 0x00000000
    Input reverse: False
    Output reverse: False
    """
    polynomial = 0x04C11DB7
    crc = prev_crc
    
    for byte in data:
        crc ^= (byte << 24)
        for _ in range(8):
            if crc & 0x80000000:
                crc = (crc << 1) ^ polynomial
            else:
                crc <<= 1
            crc &= 0xffffffff
    
    return crc

def main():
    print("CRC-32/MPEG-2 Calculator")
    print("Enter 'q' to quit")
    
    current_crc = 0xffffffff
    
    while True:
        user_input = input("\nEnter data (ASCII or hex with 0x prefix): ")
        
        if user_input.lower() == 'q':
            break
            
        try:
            # Process input
            if user_input.startswith('0x'):
                # Hex input
                hex_str = user_input[2:].replace(' ', '')
                if len(hex_str) % 2 != 0:
                    print("Error: Hex string length must be even")
                    continue
                data = bytes.fromhex(hex_str)
            else:
                # ASCII input
                data = user_input.encode('ascii')
                
            # Calculate CRC
            current_crc = crc32_mpeg2(data, current_crc)
            
            # Display results
            print(f"Input: {user_input}")
            print(f"CRC-32: 0x{current_crc:08x}")
            
        except ValueError as e:
            print(f"Error: Invalid input - {e}")
        except UnicodeEncodeError:
            print("Error: Input must be valid ASCII characters")

if __name__ == "__main__":
    main()