# HIDE: [Deprecated] Install new finsync
function installfinsync() {
	FINPATH=~/Documents/finance-project
	FINSRCPATH=$CODE_DIR/finance
	IS_INSIDE=$(insidedir $FINSRCPATH)

	if [[ ! $IS_INSIDE ]] pushd $FINSRCPATH > /dev/null
	dotnet build
	rm -rf $FINPATH/bin
	cp -r $FINSRCPATH/FinancePipeline/bin/Debug/net6.0 $FINPATH/bin
	cp $FINSRCPATH/graph-script/graph.py $FINPATH/graph.py
	if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# HIDE: [Deprecated] Sync mint with google sheets
function finsync() {
	FINPATH=~/Documents/finance-project
	CREDPATH=~/Documents/credentials/finance-pipeline
	SPREADSHEET="1pNs9XrzAQsuizWVbvq4D5yDQ4nESZpw--V7kI6tT91E"

	IS_INSIDE=$(insidedir $FINPATH)
	if [[ ! $IS_INSIDE ]] pushd $FINPATH > /dev/null

	# And, no the spreadsheet-id is not a secret/key. Nice try
	dotnet $FINPATH/bin/FinancePipeline.dll \
		hiroyagojo@gmail.com $MINT_PASS \
		--google-cred-path "$CREDPATH/finance-pipeline-325808-36b341a22811.json" \
		--filter-path "$FINPATH/filter.csv" \
		--spreadsheet-id $SPREADSHEET \
		--driver-path "$FINPATH" \
		--category-path "$FINPATH/category-file.json" \
		--mfa-secret $MFA_SECRET \
		--transactions-path "$FINPATH/transactions.csv"

	if [[ $? -eq 0 ]]
	then
		python3 $FINPATH/graph.py $FINPATH/transactions.csv
		open -a "Google Chrome" https://docs.google.com/spreadsheets/d/${SPREADSHEET}
	else
		echo "Finsync failed"
	fi

	if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# HIDE: [Deprecated] Open python playground in jupyter notebook
function pyplay() {
	PORTS=$(jupyter notebook list --jsonlist | jq '.[].port')
	if [[ $PORTS != *"8889"* ]]; then
		nohup jupyter notebook --notebook-dir=$SCRIPTS_DIR/notebook --port 8889 --no-browser >/dev/null 2>&1 &
		sleep 1
	fi

	open -a "Google Chrome" http://localhost:8889/notebooks/play.ipynb
}