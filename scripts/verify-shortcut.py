#!/usr/bin/env python3
"""Check the committed workflow's references, guards, and restricted action set."""
import importlib.util
import plistlib
from pathlib import Path

root = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location("generator", root / "scripts/generate-window-shortcut.py")
generator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(generator)
workflow = plistlib.loads((root / "Shortcuts/SpectacleWindowBridge.plist").read_bytes())
assert workflow == generator.generate(), "Regenerate the companion source after modifying its generator"
allowed = {"comment", "getvalueforkey", "conditional", "gettext", "output", "filter.windows",
           "count", "getitemfromlist", "resizewindow", "movewindow"}
actions = workflow["WFWorkflowActions"]
ids = set()
groups = []
references = set()


def visit(value):
    if isinstance(value, dict):
        if value.get("Type") == "ActionOutput":
            references.add(value["OutputUUID"])
        for child in value.values():
            visit(child)
    elif isinstance(value, list):
        for child in value:
            visit(child)


for action in actions:
    kind = action["WFWorkflowActionIdentifier"].removeprefix(generator.PREFIX)
    assert kind in allowed, f"Unexpected action: {kind}"
    parameters = action["WFWorkflowActionParameters"]
    identifier = parameters["UUID"]
    assert identifier not in ids, "Duplicate output identifier"
    visit(parameters)
    assert references <= ids, "Forward or dangling variable reference"
    ids.add(identifier)
    if kind == "conditional":
        group = parameters["GroupingIdentifier"]
        if parameters["WFControlFlowMode"] == 0:
            groups.append(group)
        else:
            assert groups.pop() == group, "Unbalanced conditional"
assert not groups
find = next(a["WFWorkflowActionParameters"] for a in actions if a["WFWorkflowActionIdentifier"].endswith("filter.windows"))
assert find["WFContentItemLimitEnabled"] is False, "Do not mask an ambiguous target with a one-window limit"
predicates = find["WFContentItemFilter"]["Value"]
assert predicates["WFActionParameterFilterPrefix"] == 1, "All identity predicates must match"
assert {p["Property"] for p in predicates["WFActionParameterFilterTemplates"]} == {
    "App Name", "X Position", "Y Position", "Width", "Height", "Is Visible"
}
names = [a["WFWorkflowActionParameters"]["CustomOutputName"] for a in actions]
assert names.index("Unique window guard end") < names.index("Resize") < names.index("Move")
print(f"Companion source verified: {len(actions)} built-in actions; no scripts or network actions.")
