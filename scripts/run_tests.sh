#!/usr/bin/env bash
# Check that every module compiles on its own, then run every self-checking
# testbench under tb/ with Icarus Verilog.
#
# Usage: scripts/run_tests.sh [--vcd] [filter]
#
#   --vcd    also write a waveform for each testbench to build/waves/<tb>.vcd
#   filter   only run testbenches whose name contains this text (e.g. "mux")
#
# Every file `include`s the files it depends on, using paths relative to the
# repository root, so iverilog is always run from the root.
#
# Exit status is 0 only if everything compiled without warnings and every
# testbench printed "PASS: <name>".

set -u
cd "$(dirname "$0")/.." || exit 2

vcd_flag=""
filter=""
for arg in "$@"; do
    case "$arg" in
        --vcd)     vcd_flag="+vcd" ;;
        -h|--help) sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -*)        echo "unknown option: $arg" >&2; exit 2 ;;
        *)         filter="$arg" ;;
    esac
done

if ! command -v iverilog >/dev/null 2>&1 || ! command -v vvp >/dev/null 2>&1; then
    echo "error: iverilog/vvp not found on PATH (install Icarus Verilog)" >&2
    exit 2
fi

mkdir -p build/waves

passed=0
failed=0
failed_names=()

# --- 1. Every RTL file must compile standalone (no warnings) ----------------
if [ -z "$filter" ]; then
    while IFS= read -r src; do
        log=$(iverilog -g2005 -Wall -t null "$src" 2>&1)
        if [ $? -ne 0 ] || [ -n "$log" ]; then
            echo "FAIL: $src (compile)"
            echo "$log" | sed 's/^/  /'
            failed=$((failed + 1)); failed_names+=("$src")
        else
            passed=$((passed + 1))
        fi
    done < <(find rtl -name '*.v' | sort)
    echo "compiled rtl/: $passed files ok"
fi

# --- 2. Run every testbench --------------------------------------------------
while IFS= read -r tb; do
    name=$(basename "$tb" .v)
    if [ -n "$filter" ] && [[ "$name" != *"$filter"* ]]; then
        continue
    fi

    # Compile. Any warning (-Wall) counts as a failure so the code stays clean.
    compile_log=$(iverilog -g2005 -Wall -s "$name" -o "build/$name.vvp" "$tb" 2>&1)
    compile_status=$?
    if [ $compile_status -ne 0 ] || [ -n "$compile_log" ]; then
        echo "FAIL: $name (compile)"
        echo "$compile_log" | sed 's/^/  /'
        failed=$((failed + 1)); failed_names+=("$name")
        continue
    fi

    # Run. The testbench prints exactly one "PASS: <name>" or "FAIL: <name>" line.
    # shellcheck disable=SC2086  # vcd_flag is intentionally unquoted so it can be empty
    output=$(vvp -n "build/$name.vvp" $vcd_flag 2>&1)
    if grep -q "^PASS: $name\$" <<<"$output" && ! grep -q "FAIL" <<<"$output"; then
        echo "PASS: $name"
        passed=$((passed + 1))
    else
        echo "$output" | grep -v '\$finish called' | sed 's/^/  /'
        echo "FAIL: $name"
        failed=$((failed + 1)); failed_names+=("$name")
    fi
done < <(find tb -name '*_tb.v' | sort)

total=$((passed + failed))
echo
if [ "$total" -eq 0 ]; then
    echo "Nothing matched."
    exit 2
fi
echo "$passed/$total passed"
if [ "$failed" -ne 0 ]; then
    echo "failed: ${failed_names[*]}"
    exit 1
fi
