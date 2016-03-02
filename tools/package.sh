#!/bin/sh

# this script:
# - clones git repo into your /tmp/ directory
# - zip the archive for the layer
# - uploads to s3


# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
layer="doubanMovie"
verbose=0
tmp="/tmp/"

while getopts "h?vl:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    v)  verbose=1
        ;;
    l)  layer=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

echo "verbose=$verbose, layer='$layer', Leftovers: $@"

timestamp=`date +%Y%m%d%m%s`

temp_dir=${tmp}${layer}-${timestamp}

# pack up from git
git clone https://github.com/stonemary/Mercury.git $temp_dir
cd $temp_dir

# archive folder sepecific for layer
if [[ "$layer" == "doubanMovie" ]]
  then
    git archive --format zip HEAD $layer > ${temp_dir}.zip
fi

# upload to S3
aws s3 cp ${temp_dir}.zip s3://software.mercury.com/code/

# End of file