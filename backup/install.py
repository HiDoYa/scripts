import os
import shutil
from jinja2 import Environment, FileSystemLoader

env = Environment(loader=FileSystemLoader("."))

# Backup script
backup_script_fname = "backup.sh"

# Template plist
plist_fname = 'com.hiroyagojo.backup.plist'
unique_label = 'com.hiroyagojo.backup.rclonebackups'
scripts_dir = os.environ.get("SCRIPTS_DIR")
backup_script_path = f"{scripts_dir}/backup/{backup_script_fname}"
err_path = f"{scripts_dir}/backup/err.log"
log_path = f"{scripts_dir}/backup/out.log"
template = env.get_template(f"{plist_fname}.j2")
result = template.render(
    backup_script_path=backup_script_path,
    unique_label=unique_label,
    err_path=err_path,
    log_path=log_path,
)
with open(plist_fname, 'w') as f:
    f.write(result)

home = os.environ.get("HOME")

# Move plist
plist_dest_path = f"{home}/Library/LaunchAgents/{plist_fname}"
shutil.copyfile(plist_fname, plist_dest_path)

uid = os.getuid()

print("Run the following:")
print(f"launchctl bootout gui/{uid}/{unique_label}")
print(f"launchctl bootstrap gui/{uid} {plist_dest_path}")
print("Grant /bin/bash Full Disk Access (System Settings > Privacy) so launchd can read ~/Documents")

print("\nDebugging commands:")
print(f"launchctl print gui/{uid}/{unique_label}")
print(f"launchctl list | grep {unique_label}")
