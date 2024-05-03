#!/usr/bin/env python
import sys,os,re
dupls = {}



keyword = sys.argv[1] if len(sys.argv) > 1 else None

# discarded = [r".*\snote:\s.*"] 
errors = []
warnings = []

discard_lookup = False
colorizelines = {
    # errors in red
    r"errors?" : "\033[91m",
    # warnings in yellow 
    r"warnings?" : "\033[93m",
    # warning flags  in magenta :
    r"\[-W[a-z0-9\-_]*\]": "\033[95m",
    # filenames and paths in blue :
    r"([a-z]+:\/|\/?[a-zA-Z0-9_\-\+\.]+\/)([a-zA-Z0-9_\-\.\+]+\/)*[a-zA-Z0-9_\-\+\.]+(:[0-9]+)*" : "\033[94m",
    # line numbers in grey :
    r"([0-9]|\s)+\s\|\s": "\033[90m",
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
    if line is None :
        return None
    # if keyword in line:
    #     return line
    
    if discard_lookup and re.match(r"([0-9]\s|\s)+\|\s", line):
        return None
    elif discard_lookup:
        discard_lookup = False
        
    if re.match(r".*\snote:\s.*", line):
        discard_lookup = True
        return "\033[90m      | " + line + "\033[0m"
    
    if line.startswith("In file included from"):
        return None
    
    return line

def prt(line):
    if line is None:
        return None
    
    print (line, end='')            
    return line
    
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
    
    print("\nResume :")
    if len(warnings) > 0:
        print(" - \033[93mWarnings:\033[0m")
        for warning in warnings:
            print("   | "+warning, end='')
    else:
        print(" - \033[92mNo warning found.\033[0m")
        
    if len(errors) > 0:
        print(" - \033[91mErrors:\033[0m")
        for error in errors:
            print("    | "+error, end='')
    else:
        print(" - \033[92mNo error found.\033[0m")