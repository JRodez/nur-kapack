#!/usr/bin/env python
import sys, os, re

dupls = {}

632

class color:
   PURPLE = '\033[95m'
   CYAN = '\033[96m'
   DARKCYAN = '\033[36m'
   BLUE = '\033[94m'
   GREEN = '\033[92m'
   YELLOW = '\033[93m'
   RED = '\033[91m'
   GREY = '\033[90m'
   BOLD = '\033[1m'
   UNDERLINE = '\033[4m'
   END = '\033[0m'

keyword = sys.argv[1] if len(sys.argv) > 1 else None

# discarded = [r".*\snote:\s.*"]
errors = []
warnings = []

discard_lookup = False
colorizelines = {
    # errors in red
    r"errors?": color.RED,
    # warnings in yellow
    r"warnings?": color.YELLOW,
    # warning flags  in magenta :
    r"\[-W[a-z0-9\-_]*\]": color.PURPLE,
    # filenames and paths in blue :
    r"([a-z]+:\/|\/?[a-zA-Z0-9_\-\+\.]+\/)([a-zA-Z0-9_\-\.\+]+\/)*[a-zA-Z0-9_\-\+\.]+(:[0-9]+)*": color.BLUE,
    # line numbers in grey :
    r"([0-9]|\s)+\s\|\s": color.GREY,
}


def remove_duplicate(line):
    if line is None:
        return None

    if line not in dupls:
        dupls[line] = True
        return line
    return None


def contains_keyword(line):
    global discard_lookup
    if line is None:
        return None
    # if keyword in line:
    #     return line

    if discard_lookup and re.match(r"([0-9]\s|\s)+\|\s", line):
        return None
    elif discard_lookup:
        discard_lookup = False

    if re.match(r".*\snote:\s.*", line):
        discard_lookup = True
        return f"{color.GREY}      | {line}{color.END}"

    if line.startswith("In file included from"):
        return None

    return line


def prt(line):
    if line is None:
        return None
    stripped = line.rstrip()
    print(stripped, end="\n",flush=True)
    return stripped.lstrip()


def colorize(line):
    if line is None:
        return None

    for pattern in colorizelines:
        line = re.sub(pattern, colorizelines[pattern] + r"\g<0>\033[0m", line)
    return line


def register(line):
    global errors, warnings
    if line is None:
        return None

    if "error\033[0m:" in line:
        errors.append(line)
    elif "warning\033[0m:" in line:
        warnings.append(line)
    return line


if __name__ == "__main__":
    for line in sys.stdin:
        register(prt(colorize(contains_keyword(remove_duplicate(line)))))
    print("", end="",flush=True)
    print("\n", end="",flush=True)
    
    print(f"{color.BOLD}Resume{color.END}")
    if len(warnings) > 0:
        print(f"├─{color.YELLOW}Warnings{color.END}")
        for i, warning in enumerate(warnings):
            print(f"│  {'├'if i+1 < len(warnings) else '└'}─ " + warning.strip(), end="\n")
    else:
        print(f"├─{color.GREEN}No warning found.{color.END}")

    if len(errors) > 0:
        print(f"└─{color.RED}Errors{color.END}")
        for i, error in enumerate(errors):
            print(f"   {'├'if i+1 < len(errors) else '└'}─ " + error.strip(), end="\n")
    else:
        print(f"└─{color.GREEN}No error found.{color.END}")
