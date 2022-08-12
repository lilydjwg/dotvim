WORK_DIR=$(cd "$(dirname "$0")"; pwd)
REPO_PATH=$1
GIT_USER_EMAIL=$2
GIT_USER_NAME=$3
GIT_USER_TOKEN=$4
if test "1" = "0" \
    || test "x-$REPO_PATH" = "x-" \
    || test "x-$GIT_USER_EMAIL" = "x-" \
    || test "x-$GIT_USER_NAME" = "x-" \
    || test "x-$GIT_USER_TOKEN" = "x-" \
    ; then
    exit 1
fi

_OLD_DIR=$(pwd)
cd "$REPO_PATH"

PUSH_URL=`git remote -v | grep "(push)"`
PUSH_URL=`echo $PUSH_URL | sed -e "s/origin[^a-z]*//g"`
PUSH_URL=`echo $PUSH_URL | sed -e "s/ *(push)//g"`
PUSH_URL=`echo $PUSH_URL | sed -e "s#://#://$GIT_USER_NAME:$GIT_USER_TOKEN@#g"`

git config user.email "$GIT_USER_EMAIL"
git config user.name "$GIT_USER_NAME"
git add -A
git commit -m "update"
git push "$PUSH_URL" HEAD
if ! test "$?" = "0"; then
    cd "$_OLD_DIR"
    exit 1
fi
git fetch "$PUSH_URL" "+refs/heads/*:refs/remotes/origin/*"

cd "$_OLD_DIR"

exit 0

