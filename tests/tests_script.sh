#!/bin/bash

# Path to your compiled calculator
EXEC="./build/main"
LOG="./tests/test_results.log"
rm -f "$LOG"

# Define test cases as: input | expected_output
TESTS=(
  $'1\n2\n1\n| Output: 3'              # 1 + 2
  $'4\n2\n2\n| Output: 2'              # 4 - 2
  $'3\n3\n3\n| Output: 9'              # 3 * 3
  $'5\n5\n3\n| Output: I'              # 5 * 5 = 25 = I
  $'9\n3\n4\n| Output: 3'              # 9 / 3
  $'22\n2\n1\n| ERROR: one digit max'  # invalid num1
  $'2\n22\n1\n| ERROR: one digit max'  # invalid num2
  $'\n2\n1\n| ERROR: no number given'  # enter instead of input
  $'2\n0\n4\n| ERROR: cannot divide by zero'
)

echo "Running ${#TESTS[@]} tests..."

pass=0
fail=0

for i in "${!TESTS[@]}"; do
  IFS='|' read -r input expected <<< "${TESTS[$i]}"
  result=$(printf "$input" | $EXEC | tr -d '\r')
  echo "Test $((i+1)):" >> "$LOG"
  echo "Input:" >> "$LOG"
  printf "%q\n" "$input" >> "$LOG"
  echo "Output:" >> "$LOG"
  echo "$result" >> "$LOG"
  echo "---" >> "$LOG"

  if echo "$result" | grep -q "$expected"; then
    echo "✅ Test $((i+1)) passed"
    ((pass++))
  else
    echo "❌ Test $((i+1)) failed"
    echo "Expected: $expected"
    ((fail++))
  fi
done

echo "----------------------"
echo "Passed: $pass | Failed: $fail"
echo "See $LOG for full output"
