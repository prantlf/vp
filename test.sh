#!/bin/sh

set -e

test() {
  if [ "$2" != "" ]; then
    echo "----------------------------------------"
  fi
  echo "$1"
  echo "----------------------------------------"
}

test "help"
./vp -h

test "version" 1
./vp -V

LINK="$HOME/.vmodules/prantlf/vp"

echo "----------------------------------------"
echo "clean up"
rm -rf "$LINK"

test "link" 1
./vp link
if [ ! -L "$LINK" ]; then
  echo "link not created"
  exit 1
fi

test "unlink" 1
./vp unlink
if [ -L "$LINK" ]; then
  echo "link not removed"
  exit 1
fi

echo "----------------------------------------"
echo "done"
