#!/bin/sh

# this script:
# - clones git repo into your /tmp/ directory
# - zip the archive for the layer
# - uploads to s3

## options
# -l layer
# -t type: cookbooks or code


# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
layer="doubanMovie"
verbose=0
tmp="/tmp/"
type="code"

while getopts "h?vt:l:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    v)  verbose=1
        ;;
    t)  type=$OPTARG
        ;;
    l)  layer=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

echo "verbose=$verbose, layer='$layer', Leftovers: $@"

timestamp=`date +%Y%m%d%m%s`

temp_dir=${tmp}${type}-${layer}-${timestamp}

# pack up from git
git clone https://github.com/stonemary/Mercury.git $temp_dir
cd $temp_dir

# archive folder sepecific for layer
if [[ "$type" == "$code" ]]
  then
    if [[ "$layer" == "doubanMovie" ]]
      then
        git archive --format zip HEAD $layer > ${temp_dir}.zip
    fi
  else
    if [[ "$layer" == "doubanMovie" ]]
      then
        git archive --format zip HEAD cookbooks/mercury-crawler > ${temp_dir}.zip
    fi
fi

# upload to S3
aws s3 cp ${temp_dir}.zip s3://software.mercury.com/${type}/

# End of file