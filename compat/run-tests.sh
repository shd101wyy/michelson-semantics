#!/usr/bin/env bash

# either validates that all expected tests pass or marks which tests fail
# when the first argument is "record", then do mark failing tests
# when there are no arguments, then validate all expected tests pass

SCRIPT_DIRECTORY="$(dirname "$(readlink -f "$BASH_SOURCE")")"
RECORD_FILE="$SCRIPT_DIRECTORY/failed_tests.txt"
TEST_DIR="$SCRIPT_DIRECTORY/../tests/unit"

failed=0
record=0

if [ "$1" == "record" ]; then
  record=1
  > "$RECORD_FILE"
elif [ $# -ge 1 ] || [ ! -f "$RECORD_FILE" ]; then
  echo "usage: run-tests.sh [record]"
  echo "       Must execute:"
  echo "       > run-tests.sh record"
  echo "       BEFORE running:"
  echo "       > run-tests.sh"
  exit 1
fi

for test in $(ls "$TEST_DIR");
do
  # run test and get actual return value
  "$SCRIPT_DIRECTORY/run-test.sh" "$TEST_DIR/$test" &> /dev/null
  actual=$(( $? ? 1 : 0))
  # get expected value of test
  if [ $record -eq 1 ]; then
    expected=0
  else
    grep -Fxq -- "$test" "$RECORD_FILE"
    expected=$(( $? ? 0 : 1))
  fi
  # check whether test results agree and record result
  if [ $actual -ne $expected ]; then
    echo "$test"
    failed=1
    if [ $record -eq 1 ]; then
      echo "$test" >> "$RECORD_FILE"
    fi
  fi
done

if [ $record -eq 0 ] && [ $failed -eq 1 ]; then
  echo "test cross-validation failed on above tests"
  exit 1
fi