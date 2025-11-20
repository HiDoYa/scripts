# TITLE: Code

# Update version, compatible with uv/poetry/file (vupdate 1.2.3)
alias vupdate="vupdate"

# Update changelog with a version (changelog-inc 1.2.3)
alias changelog-inc="changelog-inc"

# Summarize work done into various formats
alias wsum="wsum"

# Copilot but run via CLI
alias localpilot="localpilot"

# Docker ps
function dps() {
    docker ps --format "---
name: {{.Names}} [{{.ID}}] [{{.Status}}]
imag: {{.Image}}{{if .Ports}}
port: {{.Ports}}{{end}}" \
| awk '
  /^---/ {print "\033[35m" $0 "\033[0m"; next}   # magenta delimiter
  /^name:/ {
    # Color ID in cyan
    gsub(/\[[0-9a-f]{12}\]/, "\033[36m&\033[0m")
    # Color Status green if Up, red otherwise
    if ($0 ~ /\[Up/) {gsub(/\[Up[^\]]*\]/, "\033[32m&\033[0m")}
    else {gsub(/\[[^\]]+\]/, "\033[31m&\033[0m")}
    print; next
  }
  {print}
'
}
