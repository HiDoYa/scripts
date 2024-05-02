# HIDE: Function to check if inside a directory
function insidedir() { [[ $(pwd) == $1 ]] }

# Edit zshrc files
alias zshedit='code $SCRIPTS_DIR -g $SCRIPTS_DIR/dotfiles/zshrc/05-general.zshrc'

# Reload zshrc file
alias rezsh='source ~/.zshrc'

# Tmux save buffer
alias tmux-save-all='tmux capture-pane -pS -'

# Tmux save buffer since last prompt
function tmux-save()
{
	# Number of commands to capture
	# Lookback + 1 since we want to ignore our current command itself
	LOOKBACK=$((1+${1:-1}))

	BUFFER=$(tmux capture-pane -pS -)
	LNOS=$(echo $BUFFER | grep -ne '^hiroya\.gojo.*' | tail -${LOOKBACK} | cut -d":" -f1)
	FRST=$(echo $LNOS | head -n 1)
	LAST=$(($(echo $LNOS | tail -n 1) - 1))
	echo $BUFFER | sed -n "${FRST},${LAST}p"
}

# Display all commands
alias cmds='$SCRIPTS_DIR/cmds/cmds.rb ~/.zshrc'

# Point calculator (-s 12/12/23 -p 10)
alias pointcalc='$SCRIPTS_DIR/pointcalc/pointcalc.rb -f $SCRIPTS_DIR/pointcalc/holidays.yaml'

# Install vim vundle plugins
alias vimplugin='vim +PluginInstall +qall'

# Performs brew maintenance
function brewing()
{
	# Ruby
	gem update

	# Brew
	brew update
	brew upgrade
	brew outdated
	brew cleanup

	# Node js
	npm update -g

	# Python
	# pip3 list --outdated --format=json | jq -r '.[] | "\(.name)==\(.latest_version)"' | xargs -n1 pip3 install -U
}

# Secrets backup script
function sbackup()
{
	$SCRIPTS_DIR/backup/backup.sh
}

# Open python playground in jupyter notebook
function pyplay()
{
	PORTS=$(jupyter notebook list --jsonlist | jq '.[].port')
	if [[ $PORTS != *"8889"* ]]; then
		nohup jupyter notebook --notebook-dir=$SCRIPTS_DIR/notebook --port 8889 --no-browser >/dev/null 2>&1 &
		sleep 1
	fi

	open -a "Google Chrome" http://localhost:8889/notebooks/play.ipynb
}

# Convert HEIC formatted photos to jpeg in a folder
function heic2jpg()
{
	WORK_DIR=$(pwd)
	if [[ $1 ]]; then
		WORK_DIR=$1
	fi

	for i in $WORK_DIR/*.HEIC; do
		sips -s format jpeg "$i" --out "$i.jpg"
	done

	for i in $WORK_DIR/*.heic; do
		sips -s format jpeg "$i" --out "$i.jpg"
	done
}

# Unzip all .zip files in a directory in a flat structure
function unzipall()
{
	WORK_DIR=$(pwd)
	if [[ $1 ]]; then
		WORK_DIR=$1
	fi

	for i in *.zip; do
		unzip -j $i
	done
}

# Display all extensions in folder (use -r for recursive, -a for hidden, -d for custom directory)
function extc() {
	LS_FLAGS=''
	DIR_PATH=$(pwd)
	while getopts "ard:" flag; do
		case "${flag}" in
			r) LS_FLAGS=${LS_FLAGS}R ;;
			a) LS_FLAGS=${LS_FLAGS}a ;;
			d) dirpath=${OPTARG} ;;
		esac
	done

	ls -p${LS_FLAGS} $DIR_PATH | grep -v / | grep -v -e '^$' | perl -ne 'print lc' | awk -F . '{print $NF}' | sort | uniq -c | sort
}
