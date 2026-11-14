#!/usr/bin/env bash
# The demo-sync oracle: plays demo1-3 of freedoom2.wad headless with one variant's modules and
# holds each tic line ("tic=<n> cs=<game state hash> fb=<frame hash>") to the native build's
# reference log in ref/. Exit 0 when every demo is in sync and ends in `timed N gametics`.
#
#   ./check.sh <ugly|processed> [interp|jit] [options] [-- extra program arguments]
#     --demo N        only demo N (repeatable; default 1 2 3)
#     --state-only    compare tic and cs only; count the tics whose frame (fb) differs
#     --grep PREFIX   per demo, the count and sha256 of the output lines starting with PREFIX
#     --keep DIR      keep each demo's full output as DIR/demo<N>.txt
#     -- ARGS...      appended to the program's command line after `-timedemo demo<N>`
#
# Environment: DASLANG_ROOT (default /root/daScript) a built daScript checkout, or DASLANG its
# bin/daslang (then DASLANG_ROOT is the folder above its bin/); WAD (default ./freedoom2.wad, which
# ./fetch_wad.sh downloads); TIMEOUT seconds per demo (default 900). The runtime the modules need is
# runtime/ here: c_runtime/ loads as it is, and dasCRuntime/ (the `crt` native module) is built on
# first use with cmake and a C++17 compiler against DASLANG_ROOT's include/ and lib/, into
# runtime/dasCRuntime/_build, and rebuilt when DASLANG_ROOT changes. C2DAS (optional) a c2das-re
# checkout with scripts/build_crt.sh run: its c_runtime/ and dasCRuntime/ are used instead, and its
# doom/fetch/wads/freedoom2.wad is the default WAD.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
usage() { sed -n '6,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' >&2; exit 2; }
[ $# -ge 1 ] || usage
variant=$1; shift
case "$variant" in ugly|processed) ;; *) usage ;; esac
tier=interp
if [ $# -ge 1 ] && { [ "$1" = interp ] || [ "$1" = jit ]; }; then tier=$1; shift; fi
demos=(); state_only=0; grep_prefix=""; keep=""; extra=()
while [ $# -gt 0 ]; do
    case "$1" in
        --demo) demos+=("$2"); shift 2 ;;
        --state-only) state_only=1; shift ;;
        --grep) grep_prefix=$2; shift 2 ;;
        --keep) keep=$2; shift 2 ;;
        --) shift; extra=("$@"); break ;;
        *) usage ;;
    esac
done
[ ${#demos[@]} -gt 0 ] || demos=(1 2 3)
if [ -n "${DASLANG:-}" ]; then
    DASLANG_ROOT=${DASLANG_ROOT:-$(cd "$(dirname "$DASLANG")/.." && pwd)}
else
    DASLANG_ROOT=${DASLANG_ROOT:-/root/daScript}
    DASLANG=$DASLANG_ROOT/bin/daslang
fi
[ -x "$DASLANG" ] || { echo "check: no daslang at $DASLANG (set DASLANG or DASLANG_ROOT)" >&2; exit 2; }
DASLANG_ROOT=$(cd "$DASLANG_ROOT" && pwd)
if [ -n "${C2DAS:-}" ]; then
    C2DAS=$(cd "$C2DAS" && pwd)
    runtime=$C2DAS
    WAD=${WAD:-$C2DAS/doom/fetch/wads/freedoom2.wad}
    ls "$runtime"/dasCRuntime/*.shared_module > /dev/null 2>&1 || { echo "check: crt not built in $C2DAS (run scripts/build_crt.sh)" >&2; exit 2; }
else
    runtime=$here/runtime
    WAD=${WAD:-$here/freedoom2.wad}
    build=$runtime/dasCRuntime/_build
    # the module shares the ABI of the daslang that loads it: built once per DASLANG_ROOT
    if ! ls "$runtime"/dasCRuntime/*.shared_module > /dev/null 2>&1 || [ "$(cat "$build/daslang_root" 2>/dev/null)" != "$DASLANG_ROOT" ]; then
        echo "check: building runtime/dasCRuntime against $DASLANG_ROOT" >&2
        { cmake -S "$runtime/dasCRuntime" -B "$build" -DDASLANG_ROOT="$DASLANG_ROOT" -DCMAKE_BUILD_TYPE=Release \
            && cmake --build "$build" --config Release -- -j"$(nproc 2>/dev/null || echo 4)"; } > "$build.log" 2>&1 \
            || { tail -20 "$build.log" >&2; echo "check: the crt build failed, its log is $build.log" >&2; exit 2; }
        echo "$DASLANG_ROOT" > "$build/daslang_root"
    fi
fi
TIMEOUT=${TIMEOUT:-900}
[ -f "$WAD" ] || { echo "check: no wad at $WAD (run ./fetch_wad.sh, or set WAD)" >&2; exit 2; }
main="$here/$variant/doom/doom_main.das"
jit=(); [ "$tier" = jit ] && jit=(-jit)
[ -n "$keep" ] && mkdir -p "$keep"
tmp=$(mktemp -d)
trap 'rm -rf "${tmp:?}"' EXIT
ln -s "$(cd "$(dirname "$WAD")" && pwd)/$(basename "$WAD")" "$tmp/doom2.wad"
fail=0
for demo in "${demos[@]}"; do
    ref="$here/ref/freedoom2_demo$demo.log"
    [ -f "$ref" ] || { echo "demo$demo: no reference log $ref" >&2; fail=1; continue; }
    out="$tmp/demo$demo.txt"
    rc=0
    (cd "$tmp" && DOOMWADDIR="$tmp" timeout "$TIMEOUT" "$DASLANG" -load_module "$runtime/dasCRuntime" -load_module "$runtime/c_runtime" "${jit[@]}" "$main" -- -timedemo "demo$demo" "${extra[@]}") > "$out" 2>&1 || rc=$?
    [ -n "$keep" ] && cp "$out" "$keep/demo$demo.txt"
    if [ "$state_only" = 1 ]; then fields='$1" "$2'; else fields='$1" "$2" "$3'; fi
    grep '^tic=' "$ref" | awk "{print $fields}" > "$tmp/want"
    grep '^tic=' "$out" | awk "{print $fields}" > "$tmp/got" || true
    want_n=$(wc -l < "$tmp/want"); got_n=$(wc -l < "$tmp/got")
    first=$(cmp "$tmp/want" "$tmp/got" 2>/dev/null | sed -n 's/.* line \([0-9]*\).*/\1/p' || true)
    if [ -z "$first" ] && [ "$want_n" != "$got_n" ]; then first=$(( (want_n < got_n ? want_n : got_n) + 1 )); fi
    verdict=""
    if [ -n "$first" ]; then
        verdict="DESYNC at tic line $first: want '$(sed -n "${first}p" "$tmp/want")', got '$(sed -n "${first}p" "$tmp/got")'"
        err=$(grep -i -m1 -E 'error|exception|panic' "$out" | grep -v 'timed [0-9]* gametics' || true)
        [ -n "$err" ] && verdict="$verdict; first error: $err"
    elif ! grep -q "timed $want_n gametics" "$out"; then
        verdict="all $want_n tics in sync but the run did not end in 'timed $want_n gametics' (exit $rc)"
        err=$(grep -i -m1 -E 'error|exception|panic' "$out" || true)
        [ -n "$err" ] && verdict="$verdict; first error: $err"
    fi
    if [ -n "$verdict" ]; then
        echo "demo$demo $variant $tier: $verdict"
        fail=1
    else
        msg="$want_n tics in sync"
        if [ "$state_only" = 1 ]; then
            fbdiff=$(paste -d' ' <(grep '^tic=' "$ref" | awk '{print $3}') <(grep '^tic=' "$out" | awk '{print $3}') | awk '$1 != $2' | wc -l)
            msg="$want_n tics, game state in sync; frame differs on $fbdiff tics"
        fi
        echo "demo$demo $variant $tier: $msg"
    fi
    if [ -n "$grep_prefix" ]; then
        P="$grep_prefix" awk 'index($0, ENVIRON["P"]) == 1' "$out" > "$tmp/matched"
        lines=$(wc -l < "$tmp/matched")
        sum=$(sha256sum < "$tmp/matched" | cut -c1-16)
        echo "demo$demo $variant $tier: $lines lines starting '$grep_prefix', sha256 $sum"
    fi
done
exit $fail
