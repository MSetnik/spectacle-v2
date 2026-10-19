#!/usr/bin/env python3
"""Generate the inspectable companion workflow. This command never uploads or signs it."""
import argparse
import plistlib
import uuid
from pathlib import Path

NAME = "Spectacle Window Bridge"
PREFIX = "is.workflow.actions."
NAMESPACE = uuid.UUID("2551c67d-25ec-4425-937b-ebed6c3243d8")


def identifier(label):
    return str(uuid.uuid5(NAMESPACE, label)).upper()


def attachment(value):
    return {"Value": value, "WFSerializationType": "WFTextTokenAttachment"}


def reference(label):
    return attachment({"Type": "ActionOutput", "OutputUUID": identifier(label), "OutputName": label})


def text_with_reference(prefix, label, suffix=""):
    return {"Value": {"string": prefix + "\ufffc" + suffix,
                      "attachmentsByRange": {"{%d, 1}" % len(prefix): reference(label)["Value"]}},
            "WFSerializationType": "WFTextTokenString"}


def generate():
    actions = []

    def action(kind, label, **parameters):
        parameters["UUID"] = identifier(label)
        parameters["CustomOutputName"] = label
        actions.append({"WFWorkflowActionIdentifier": PREFIX + kind,
                        "WFWorkflowActionParameters": parameters})

    def read(key):
        action("getvalueforkey", key, WFDictionaryKey=key,
               WFInput=attachment({"Type": "ExtensionInput"}))

    def reply(status, label):
        action("gettext", label,
               WFTextActionText=text_with_reference('{"protocol":2,"requestID":"', "requestID",
                                                   '","status":"' + status + '"}'))
        action("output", label + " output", WFOutput=reference(label))

    def start_if(label, value, condition, **rhs):
        action("conditional", label, WFInput=reference(value), WFCondition=condition,
               WFControlFlowMode=0, GroupingIdentifier=identifier(label + " group"), **rhs)

    def end_if(label):
        action("conditional", label + " end", WFControlFlowMode=2,
               GroupingIdentifier=identifier(label + " group"))

    action("comment", "About", WFCommentActionText=
           "Companion for Spectacle. Receives a JSON request from the app. Uses only built-in window "
           "actions. No network, shell scripts, clipboard, or document access. Keep this Shortcut's name. "
           "A move is allowed only when exactly one visible window matches the captured app and frame.")
    for key in ("requestID", "protocol", "operation"):
        read(key)
    start_if("Protocol guard", "protocol", 5, WFNumberValue=2)
    reply("incompatible", "Incompatible protocol")
    end_if("Protocol guard")
    start_if("Probe", "operation", 4, WFConditionalActionString="probe")
    reply("ok", "Connection verified")
    end_if("Probe")
    start_if("Operation guard", "operation", 5, WFConditionalActionString="move")
    start_if("Resize operation guard", "operation", 5, WFConditionalActionString="resize")
    reply("invalid", "Invalid operation")
    end_if("Resize operation guard")
    end_if("Operation guard")
    for key in ("app", "beforeX", "beforeY", "beforeWidth", "beforeHeight", "x", "y", "width", "height"):
        read(key)
    predicates = []
    for prop, key, value_type in (("App Name", "app", "String"), ("X Position", "beforeX", "Number"),
                                  ("Y Position", "beforeY", "Number"), ("Width", "beforeWidth", "Number"),
                                  ("Height", "beforeHeight", "Number")):
        predicates.append({"Property": prop, "Operator": 4, "Removable": True,
                           "Values": {value_type: text_with_reference("", key), "Unit": 4}})
    predicates.append({"Property": "Is Visible", "Operator": 4, "Removable": True,
                       "Values": {"Bool": True, "Unit": 4}})
    action("filter.windows", "Matching windows", WFContentItemLimitEnabled=False,
           WFContentItemFilter={"Value": {"WFActionParameterFilterPrefix": 1,
                                          "WFContentPredicateBoundedDate": False,
                                          "WFActionParameterFilterTemplates": predicates},
                                "WFSerializationType": "WFContentPredicateTableTemplate"})
    action("count", "Window count", Input=reference("Matching windows"), WFCountType="Items")
    start_if("Unique window guard", "Window count", 5, WFNumberValue=1)
    reply("target-changed", "Target changed")
    end_if("Unique window guard")
    action("getitemfromlist", "Target window", WFInput=reference("Matching windows"), WFItemSpecifier="First Item")
    # Exactly one geometry mutation per invocation; the app waits for settled bounds
    # before the next call, avoiding stale-height calculations inside Shortcuts.
    start_if("Resize request", "operation", 4, WFConditionalActionString="resize")
    action("resizewindow", "Resize", WFWindow=reference("Target window"), WFConfiguration="Dimensions",
           WFWidth=reference("width"), WFHeight=reference("height"), WFBringToFront=False)
    reply("ok", "Resize completed")
    end_if("Resize request")
    action("movewindow", "Move", WFWindow=reference("Target window"), WFPosition="Coordinates",
           WFXCoordinate=reference("x"), WFYCoordinate=reference("y"), WFBringToFront=False)
    reply("ok", "Move completed")
    return {"WFWorkflowName": NAME, "WFWorkflowClientVersion": "2600",
            "WFWorkflowMinimumClientVersion": 900, "WFWorkflowMinimumClientVersionString": "900",
            "WFWorkflowIcon": {"WFWorkflowIconStartColor": 4282601983, "WFWorkflowIconGlyphNumber": 59511},
            "WFWorkflowInputContentItemClasses": ["WFStringContentItem"],
            "WFWorkflowOutputContentItemClasses": ["WFStringContentItem"],
            "WFWorkflowHasOutputFallback": False, "WFWorkflowHasShortcutInputVariables": True,
            "WFWorkflowTypes": [], "WFQuickActionSurfaces": [], "WFWorkflowImportQuestions": [],
            "WFWorkflowActions": actions}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path,
                        default=Path(__file__).resolve().parent.parent / "Shortcuts" / "SpectacleWindowBridge.plist")
    parser.add_argument("--binary", action="store_true",
                        help="Write an unsigned binary .shortcut for Apple's signing command")
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("wb") as handle:
        plistlib.dump(generate(), handle, sort_keys=False,
                      fmt=plistlib.FMT_BINARY if args.binary else plistlib.FMT_XML)
    print(args.output)
