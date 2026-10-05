"""Merge the versioned Docker settings into the user's configuration."""

import json
import os
from pathlib import Path
import tempfile


def configure(source, target):
    patch = json.loads(source.read_text())
    config = json.loads(target.read_text()) if target.exists() else {}
    if not isinstance(config, dict):
        raise ValueError("Docker config.json must contain a JSON object")
    config.update(patch)
    target.parent.mkdir(parents=True, exist_ok=True)
    # Write atomically, keeping credential data private.
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", dir=target.parent, delete=False, encoding="utf-8"
        ) as output:
            temporary = Path(output.name)
            json.dump(config, output, indent=2)
            output.write("\n")
        os.replace(temporary, target)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


if __name__ == "__main__":
    configure(
        Path(__file__).resolve().parent / "docker-config.json",
        Path.home() / ".docker/config.json",
    )
