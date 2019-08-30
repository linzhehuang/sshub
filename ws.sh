# Append following code to your profile, such as ~/.bashrc .
# 
# alias ws="source ws.sh ${your_workspace_path} "
#

if [ ! $1 ]; then
	echo "Not specific workspace path!" >&2
fi

if [ "$2" = '-l' ]; then
	ls $1
else
	# The second variable is subdirecotry.
	if [ ! $2 ]; then
		cd $1
	else
		cd $1/$2
	fi
fi

