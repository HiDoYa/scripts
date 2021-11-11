BEGIN {
	RS="\n\n";
	i=0;
}
{
	if (NR > 1) {
		fname="cat_songs/cat_song" i ".txt";
		print > fname;
		i++;
	}
}
