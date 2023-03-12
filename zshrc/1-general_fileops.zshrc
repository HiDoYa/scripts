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
