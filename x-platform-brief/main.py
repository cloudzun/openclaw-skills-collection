#!/usr/bin/env python3
"""
Python wrapper for X Platform Brief skill
This file exists to satisfy cron job configurations that expect a main.py file.
It simply calls the actual main.sh script.
"""

import subprocess
import sys
import os

def main():
    """Main function that executes the X Platform Brief shell script."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    main_sh_path = os.path.join(script_dir, 'main.sh')
    
    try:
        # Execute the main.sh script
        result = subprocess.run(['bash', main_sh_path], 
                              capture_output=True, 
                              text=True, 
                              check=True)
        
        # Print the output
        print(result.stdout)
        if result.stderr:
            print("STDERR:", result.stderr, file=sys.stderr)
            
        return result.returncode
        
    except subprocess.CalledProcessError as e:
        print(f"Error executing main.sh: {e}")
        print("STDOUT:", e.stdout)
        print("STDERR:", e.stderr, file=sys.stderr)
        return e.returncode
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())