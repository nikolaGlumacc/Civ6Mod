import xml.etree.ElementTree as ET
import glob
import os
import sys

workspace = os.path.dirname(os.path.abspath(__file__))
mods = ["Serbia_Civ_Pack", "WW2_Overhaul"]

errors_found = False

print("=" * 60)
print("  CIV 6 MOD INTEGRITY & XML VALIDATOR")
print("=" * 60)

for mod in mods:
    mod_path = os.path.join(workspace, mod)
    if not os.path.exists(mod_path):
        continue
    
    print(f"\n[*] Checking Mod: {mod} ...")
    
    # 1. Check XML syntax in all XML and modinfo files
    xml_files = glob.glob(f"{mod_path}/**/*.xml", recursive=True) + glob.glob(f"{mod_path}/**/*.modinfo", recursive=True)
    
    for xf in xml_files:
        rel = os.path.relpath(xf, workspace)
        try:
            ET.parse(xf)
        except Exception as e:
            print(f"  [ERROR] XML Syntax Error in {rel}: {e}")
            errors_found = True

    # 2. Check modinfo file references
    modinfo_files = glob.glob(f"{mod_path}/*.modinfo")
    for mf in modinfo_files:
        try:
            tree = ET.parse(mf)
            root = tree.getroot()
            files_element = root.find("Files")
            if files_element is not None:
                for file_node in files_element.findall("File"):
                    target_file = file_node.text.strip().replace('/', os.sep).replace('\\', os.sep)
                    full_target = os.path.join(mod_path, target_file)
                    if not os.path.exists(full_target):
                        print(f"  [WARNING] File declared in {os.path.basename(mf)} missing on disk: {target_file}")
                        errors_found = True
        except Exception as e:
            print(f"  [ERROR] Failed to check {mf}: {e}")
            errors_found = True

if not errors_found:
    print("\n>>> ALL XML FILES & MODINFO DECLARATIONS ARE VALID AND PRESENT! <<<")
else:
    print("\n>>> ISSUES DETECTED. See above for details. <<<")
