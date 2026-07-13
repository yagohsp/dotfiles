#!/usr/bin/env python3
"""Parse Azure DevOps work item JSON from stdin into readable text."""
import html
import json
import re
import sys


def strip_html(text: str) -> str:
    if not text:
        return ""
    text = re.sub(r"<[^>]+>", " ", text)
    text = html.unescape(text)
    return re.sub(r"\s+", " ", text).strip()


def main() -> None:
    data = json.load(sys.stdin)
    fields = data.get("fields", {})

    print(f"ID: {data.get('id')}")
    print(f"Title: {fields.get('System.Title', '')}")
    print(f"Type: {fields.get('System.WorkItemType', '')}")
    print(f"State: {fields.get('System.State', '')}")

    assigned = fields.get("System.AssignedTo")
    if isinstance(assigned, dict):
        print(f"Assigned: {assigned.get('displayName', '')}")
    elif assigned:
        print(f"Assigned: {assigned}")

    for label, key in [
        ("Parent", "System.Parent"),
        ("Story Points", "Microsoft.VSTS.Scheduling.StoryPoints"),
        ("Sprint", "System.IterationPath"),
        ("Tags", "System.Tags"),
    ]:
        if fields.get(key):
            print(f"{label}: {fields[key]}")

    desc = strip_html(fields.get("System.Description", ""))
    if desc:
        print("\n--- Description ---")
        print(desc[:6000])

    ac = strip_html(fields.get("Microsoft.VSTS.Common.AcceptanceCriteria", ""))
    if ac:
        print("\n--- Acceptance Criteria ---")
        print(ac[:4000])

    repro = strip_html(fields.get("Microsoft.VSTS.TCM.ReproSteps", ""))
    if repro:
        print("\n--- Repro Steps ---")
        print(repro[:4000])

    relations = data.get("relations") or []
    children, parents, related = [], [], []
    for rel in relations:
        url = rel.get("url", "")
        wid = url.rsplit("/", 1)[-1]
        name = rel.get("attributes", {}).get("name", rel.get("rel", ""))
        bucket = related
        if "Child" in rel.get("rel", "") or name == "Child":
            bucket = children
        elif "Parent" in rel.get("rel", "") or name == "Parent":
            bucket = parents
        bucket.append(wid)

    if children:
        print("\n--- Child IDs ---")
        print(", ".join(children))
    if parents:
        print("\n--- Parent IDs ---")
        print(", ".join(parents))
    if related and not children:
        print("\n--- Related IDs ---")
        print(", ".join(related))


if __name__ == "__main__":
    main()
