#!/usr/bin/env python3

import json
import re
import sys
from pathlib import Path
from subprocess import PIPE, run

# The Perforce changelist numbers for .0 releases of the Unreal Engine
UNREAL_ENGINE_RELEASE_CHANGELISTS = {
    "4.27.0": 17155196,
    "5.0.0": 19505902,
    "5.1.0": 23058290,
    "5.2.0": 25360045,
    "5.3.0": 27405482,
    "5.4.0": 33043543,
    "5.5.0": 37670630,
    "5.6.0": 43139311,
    "5.7.0": 47537391,
    "5.8.0": 55116800,
}

version_file = Path(sys.argv[1])
details = json.loads(version_file.read_text(encoding="utf-8"))

if sys.argv[2] == "auto":
    if int(details["CompatibleChangelist"]) == 0:
        commit_message = run(
            ["git", "log", "-n", "1", "--format=%s%n%b"],
            cwd=version_file.parent,
            stdout=PIPE,
            stderr=PIPE,
            text=True,
            check=True,
        ).stdout.strip()

        match = re.search(r"\[CL ([0-9]+) by .+ in .+ branch\]", commit_message)

        if match is not None:
            details["Changelist"] = int(match.group(1))
        elif re.fullmatch(r"[0-9.]+ release", commit_message) is not None:
            details["Changelist"] = UNREAL_ENGINE_RELEASE_CHANGELISTS[
                f"{details["MajorVersion"]}.{details["MinorVersion"]}.{details["PatchVersion"]}"
            ]
        else:
            print(
                "Error: unable to auto-detect Changelist value for Engine/Build/Build.version, specify explicitly",
                file=sys.stderr,
            )
            sys.exit(1)
else:
    details["Changelist"] = int(sys.argv[2])

details["IsPromotedBuild"] = 1

patched_json = json.dumps(details, indent=4)
version_file.write_text(patched_json, encoding="utf-8")

print(f"PATCHED BUILD.VERSION:\n{patched_json}", file=sys.stderr)
