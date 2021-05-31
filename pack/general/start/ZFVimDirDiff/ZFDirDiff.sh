WORK_DIR=$(cd "$(dirname "$0")"; pwd)
PATH_A=$1
PATH_B=$2
if test "0" = "1" \
    || test "x-$PATH_A" = "x-" \
    || test "x-$PATH_B" = "x-" \
    ; then
    echo "usage:"
    echo "  sh ZFDirDiff.sh PATH_A PATH_B"
    exit 1
fi

if test "x-$ZFDIRDIFF_VIM" = "x-"; then
    ZFDIRDIFF_VIM=vim
fi

"$ZFDIRDIFF_VIM" -c "call ZF_DirDiff(\"$PATH_A\", \"$PATH_B\")"

