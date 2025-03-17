# Secrets backup script
function sbackup() {
	$SCRIPTS_DIR/backup/backup.sh
}

# Convert HEIC formatted photos to jpeg in a folder
function heic2jpg() {
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