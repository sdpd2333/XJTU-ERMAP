#!/usr/bin/env python3
"""Check tracked course documentation and repository hygiene using only stdlib."""

from __future__ import annotations

import posixpath
import re
import subprocess
import sys
from pathlib import Path, PurePosixPath
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
COURSE = re.compile(r"^[A-Z]{4}\d{6}-.+$")
LINK = re.compile(
    r"!?\[[^\]\n]*\]\(\s*(?:<([^>\n]+)>|([^\s)]+))"
    r"(?:\s+(?:\"[^\"]*\"|'[^']*'))?\s*\)"
)


def prose_only(text: str) -> str:
    """Blank fenced and inline code while keeping line numbers stable."""
    lines = []
    fence_char = ""
    fence_length = 0
    for line in text.splitlines():
        marker = re.match(r"^\s{0,3}(`{3,}|~{3,})(.*)$", line)
        if fence_char:
            if (marker and marker[1][0] == fence_char
                    and len(marker[1]) >= fence_length and not marker[2].strip()):
                fence_char = ""
            lines.append("")
        elif marker:
            fence_char, fence_length = marker[1][0], len(marker[1])
            lines.append("")
        else:
            lines.append(re.sub(r"(`+).*?\1", "", line))
    return "\n".join(lines)


def heading_ids(text: str) -> set[str]:
    """GitHub-style anchors for the ATX headings used in this repository."""
    ids: set[str] = set()
    # Keep the content of inline code in headings, but exclude fenced examples.
    in_fence = False
    fence_char = ""
    fence_length = 0
    for line in text.splitlines():
        marker = re.match(r"^\s{0,3}(`{3,}|~{3,})(.*)$", line)
        if marker:
            if not in_fence:
                in_fence = True
                fence_char, fence_length = marker[1][0], len(marker[1])
            elif (marker[1][0] == fence_char and len(marker[1]) >= fence_length
                  and not marker[2].strip()):
                in_fence = False
            continue
        if in_fence:
            continue
        match = re.match(r"^\s{0,3}#{1,6}\s+(.+?)(?:\s+#+)?\s*$", line)
        if not match:
            continue
        label = re.sub(r"\[([^]]+)\]\([^)]*\)", r"\1", match[1])
        base = re.sub(r"[^\w\- ]", "", label.lower()).replace(" ", "-")
        slug, suffix = base, 0
        while slug in ids:
            suffix += 1
            slug = f"{base}-{suffix}"
        ids.add(slug)
    return ids


def generated_reason(name: str) -> str | None:
    path = PurePosixPath(name)
    parts = path.parts
    if path.name.startswith("~$"):
        return "Office lock file"
    if "slprj" in parts or path.suffix.lower() in {".slxc", ".asv"}:
        return "MATLAB/Simulink cache"
    if (len(parts) > 3 and parts[0].startswith("INFT532705-")
            and parts[1] == "djl_code" and parts[3] in {"Debug", "Release"}):
        return "CCS build output"
    if path.name == "network_config.h" and "djl_code" in parts:
        return "local network credentials"
    if "__pycache__" in parts or path.suffix in {".pyc", ".pyo"}:
        return "Python cache"
    return None


def local_target(source: str, destination: str) -> tuple[str, str] | None:
    url = urlsplit(destination)
    if url.scheme or url.netloc:
        return None
    path = unquote(url.path)
    if path.startswith("/") or "\\" in path:
        raise ValueError("use a repository-relative path with forward slashes")
    target = posixpath.normpath(posixpath.join(posixpath.dirname(source), path)) if path else source
    if target == ".." or target.startswith("../"):
        raise ValueError("link escapes the repository")
    return target, unquote(url.fragment)


def audit(root: Path, files: set[str]) -> tuple[list[str], int]:
    errors: list[str] = []
    directories = {"."}
    folded: dict[str, str] = {}
    documents: dict[str, str] = {}
    for name in sorted(files):
        path = PurePosixPath(name)
        directories.update(str(parent) for parent in path.parents)
        previous = folded.setdefault(name.casefold(), name)
        if previous != name:
            errors.append(f"{name}: case-insensitive path collision with {previous}")
        reason = generated_reason(name)
        if reason:
            errors.append(f"{name}: tracked {reason}; remove it from version control")
        local = root / name
        if not local.is_file():
            errors.append(f"{name}: tracked file is missing from the working tree")
            continue
        if path.suffix.lower() == ".md":
            try:
                documents[name] = local.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                errors.append(f"{name}: Markdown must use UTF-8")

    # Directory-case collisions also break portable checkouts.
    for name in sorted(directories):
        previous = folded.setdefault(name.casefold(), name)
        if previous != name:
            errors.append(f"{name}: case-insensitive path collision with {previous}")

    anchors = {name: heading_ids(text) for name, text in documents.items()}
    root_targets: set[str] = set()
    link_count = 0
    for name, text in documents.items():
        prose = prose_only(text)
        for match in LINK.finditer(prose):
            destination = match[1] or match[2]
            location = f"{name}:{prose.count(chr(10), 0, match.start()) + 1}"
            try:
                resolved = local_target(name, destination)
            except ValueError as error:
                errors.append(f"{location}: {error}: {destination}")
                continue
            if resolved is None:
                continue
            link_count += 1
            target, fragment = resolved
            if name == "README.md":
                root_targets.add(target)
            if target not in files and target not in directories:
                errors.append(f"{location}: missing or untracked link target: {target}")
                continue
            anchor_file = posixpath.join(target, "README.md") if target in directories else target
            if fragment and anchor_file in anchors and fragment not in anchors[anchor_file]:
                errors.append(f"{location}: missing heading #{fragment} in {anchor_file}")

    if "README.md" not in documents:
        errors.append("README.md: missing readable root guide")
    courses = {name.split("/", 1)[0] for name in files if COURSE.fullmatch(name.split("/", 1)[0])}
    for course in sorted(courses):
        guide = f"{course}/README.md"
        if guide not in documents:
            errors.append(f"{guide}: missing readable course guide")
        if guide not in root_targets:
            errors.append(f"README.md: course guide is not linked: {guide}")
    return errors, link_count


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    try:
        result = subprocess.run(
            ["git", "ls-files", "-z"], cwd=ROOT, check=True, capture_output=True
        )
    except (OSError, subprocess.CalledProcessError) as error:
        print(f"Cannot read the Git index: {error}", file=sys.stderr)
        return 2
    files = set(filter(None, result.stdout.decode("utf-8").split("\0")))
    errors, links = audit(ROOT, files)
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        print(f"Failed: {len(errors)} issue(s).")
        return 1
    print(f"OK: {len(files)} tracked files; {links} local Markdown links checked.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
