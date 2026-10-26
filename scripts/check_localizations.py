#!/usr/bin/env python3
"""Fail if a String Catalog has a missing or untranslated string.

Usage:
    scripts/check_localizations.py                  # languages = those declared in the project
    scripts/check_localizations.py --languages en fr es de

Run it in CI so a new key can never ship untranslated.
"""
import argparse
import json
import pathlib
import sys

DEFAULT_LANGUAGES = ["en", "fr", "es"]
IGNORED_DIRS = {".build", "DerivedData", ".git", "build"}


def is_translated(localization: dict) -> bool:
    if "stringUnit" in localization:
        return localization["stringUnit"].get("state") == "translated"
    variations = localization.get("variations", {})
    cases = [case for variation in variations.values() for case in variation.values()]
    return bool(cases) and all(is_translated(case) for case in cases)


def check(catalog: pathlib.Path, languages: list[str]) -> list[str]:
    data = json.loads(catalog.read_text(encoding="utf-8"))
    problems = []
    for key, entry in data.get("strings", {}).items():
        if entry.get("shouldTranslate") is False:
            continue
        if entry.get("extractionState") == "stale":
            problems.append(f"{key}: stale (no longer used in code)")
        if not entry.get("comment"):
            problems.append(f"{key}: missing translator comment")
        localizations = entry.get("localizations", {})
        for language in languages:
            if language not in localizations:
                problems.append(f"{key}: missing [{language}]")
            elif not is_translated(localizations[language]):
                problems.append(f"{key}: not translated [{language}]")
    return problems


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--languages", nargs="+", default=DEFAULT_LANGUAGES)
    parser.add_argument("--root", default=pathlib.Path(__file__).resolve().parent.parent, type=pathlib.Path)
    args = parser.parse_args()

    catalogs = [
        path for path in sorted(args.root.rglob("*.xcstrings"))
        if not IGNORED_DIRS.intersection(path.parts)
    ]
    failures = 0
    for catalog in catalogs:
        problems = check(catalog, args.languages)
        relative = catalog.relative_to(args.root)
        if problems:
            failures += len(problems)
            print(f"✗ {relative}")
            for problem in problems:
                print(f"    {problem}")
        else:
            print(f"✓ {relative}")

    print(f"\n{len(catalogs)} catalog(s), languages: {', '.join(args.languages)}, {failures} problem(s)")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
