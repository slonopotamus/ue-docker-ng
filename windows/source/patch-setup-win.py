#!/usr/bin/env python3

import sys
from pathlib import Path

setup_script = Path(sys.argv[1])

code = setup_script.read_text(encoding="utf-8")

# Comment out the version selector call, since we don't need shell integration
selector_call = (
    ".\\Engine\\Binaries\\Win64\\UnrealVersionSelector-Win64-Shipping.exe /register"
)
code = code.replace(selector_call, "@rem " + selector_call)

# Add output so we can see when script execution is complete, and ensure `pause` is not called on error
code = code.replace("rem Done!", "echo Done!\r\nexit /b 0")
code = code.replace("pause", "@rem pause")

setup_script.write_text(code, encoding="utf-8")

# Print the patched code to stderr for debug purposes
print(f"PATCHED {setup_script}:\n\n{code}", file=sys.stderr)
