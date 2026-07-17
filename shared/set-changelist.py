#!/usr/bin/env python3

import json
import re
import sys
from pathlib import Path
from subprocess import PIPE, run

version_file = Path(sys.argv[1])
details = json.loads(version_file.read_text(encoding="utf-8"))

changelist_override = int(details["CompatibleChangelist"])

if sys.argv[2] == "auto":
    if changelist_override == 0:
        # Attempt to retrieve the CL number from the git commit message
        engine_root = version_file.parent.parent
        commit_message = run(
            ["git", "log", "-n", "1", "--format=%s%n%b"],
            cwd=engine_root,
            stdout=PIPE,
            stderr=PIPE,
            text=True,
        ).stdout.strip()

        # If the commit is a tagged engine release then it won't have a CL number, and using "auto" is user error
        if re.fullmatch(r"[0-9.]+ release", commit_message) is not None:
            print(
                "Error: you are attempting to automatically retrieve the CL number for a tagged Unreal Engine release.\n"
                "For hotfix releases of the Unreal Engine, a CL override is not required and should not be specified.\n"
                "For supported .0 releases of the Unreal Engine, ue4-docker ships with known CL numbers, so an override should not be necessary.",
                file=sys.stderr,
            )
            sys.exit(1)

        # Attempt to extract the CL number from the commit message
        match = re.search(r"\[CL ([0-9]+) by .+ in .+ branch\]", commit_message)
        if match is not None:
            changelist_override = int(match.group(1))
        else:
            print(
                "Error: failed to find a CL number in the git commit message! This was the commit message:\n\n"
                + commit_message,
                file=sys.stderr,
            )
            sys.exit(1)
else:
    changelist_override = int(sys.argv[2])

details["Changelist"] = changelist_override
details["IsPromotedBuild"] = 1

patched_json = json.dumps(details, indent=4)
version_file.write_text(patched_json, encoding="utf-8")

print(f"PATCHED BUILD.VERSION:\n{patched_json}", file=sys.stderr)
