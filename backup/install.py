import os
import shutil
from jinja2 import Environment, FileSystemLoader

env = Environment(loader=FileSystemLoader("."))

# Template backup
backup_script_fname = "backup.sh"
pc_purpose = os.environ.get("PC_PURPOSE")
template = env.get_template(f"{backup_script_fname}.j2")
result = template.render(pc_purpose=pc_purpose)
with open(backup_script_fname, 'w') as f:
    f.write(result)

# Template plist
plist_fname = 'com.hiroyagojo.backup.plist'
scripts_dir = os.environ.get("SCRIPTS_DIR")
backup_script_path = f"{scripts_dir}/backup/{backup_script_fname}"
err_path = f"{scripts_dir}/backup/err.log"
log_path = f"{scripts_dir}/backup/out.log"
template = env.get_template(f"{plist_fname}.j2")
result = template.render(
    backup_script_path=backup_script_path,
    err_path=err_path,
    log_path=log_path,
)
with open(plist_fname, 'w') as f:
    f.write(result)

# Move backup
home = os.environ.get("HOME")
backup_dest_path = f"{home}/Library/LaunchAgents/{backup_script_fname}"
shutil.copyfile(backup_script_fname, backup_dest_path)

# Move plist
plist_dest_path = f"{home}/Library/LaunchAgents/{plist_fname}"
shutil.copyfile(plist_fname, plist_dest_path)

print("Run the following:")
print(f"chmod +x {backup_dest_path}")
print(f"launchctl load {plist_dest_path}")
