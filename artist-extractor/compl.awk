{
	if (NR > 2) {
		print substr($0, index($0, $9))
	}
}
