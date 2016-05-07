function fast_rm {
	# if perl is readily available, use it's 'unlink' to remove stuff, it's much faster than 'rm'
	# This is a hack to keep the syntax the same as that for 'rm' and to avoid
	#  invoking 'perl -nle' a bunch of times, which would be somewhat counterproductive
	#  There's probably a smarter way using 'xargs' or something or maybe some crazy 'find'
	if [ $(which perl) ] &>/dev/null; then
		templist=
		for item in "$@"; do templist="${templist}${item}\n";done
		echo -en $templist | perl -nle unlink
	else
		# else use rm -rf as the fall back
		rm -rf "$@"
	fi
}
