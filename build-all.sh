#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# build-all.sh -- build the three MySQL compatibility modules for the
# openHalo x Babelfish fusion kernel (postgresql_modified_for_babelfish).
#
# Prerequisites: the kernel must be built and installed first (run
# babelfish_extensions/build-all.sh or ninja install in the kernel tree);
# KERNEL_DIR defaults to ../postgresql_modified_for_babelfish.  mysql_parser
# needs flex and bison for its scanner/grammar generation; gen_keywordlist.pl
# is read from the kernel source tree (PG_SRC), so KERNEL_DIR must point at
# a source checkout, not just an install.
# ---------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KERNEL_DIR="${KERNEL_DIR:-$SCRIPT_DIR/../postgresql_modified_for_babelfish}"
PREFIX="${PREFIX:-$KERNEL_DIR/inst}"

[ -d "$KERNEL_DIR" ] || { echo "kernel tree not found: $KERNEL_DIR" >&2; exit 1; }
[ -x "$PREFIX/bin/pg_config" ] || {
    echo "kernel install not found: $PREFIX/bin/pg_config" >&2
    echo 'build and install the kernel first (babelfish_extensions/build-all.sh)' >&2
    exit 1
}

for tool in make cc pkg-config flex bison perl; do
    command -v "$tool" >/dev/null 2>&1 || { echo "missing tool: $tool" >&2; exit 1; }
done

PGCONFIG="$PREFIX/bin/pg_config"

for ext in mysql_parser mysm aux_mysql; do
    echo "===== building $ext ====="
    (cd "contrib/$ext" && \
        make USE_PGXS=1 PG_CONFIG="$PGCONFIG" PG_SRC="$KERNEL_DIR" \
             -j"$(nproc)" all install)
done

echo
echo 'all three MySQL modules built and installed:'
ls "$("$PGCONFIG" --pkglibdir)" | grep -E 'mysql_parser|mysm|aux_mysql'
echo
echo 'restart any running cluster to pick up the new binaries:'
echo "  $PREFIX/bin/pg_ctl -D <data-dir> restart"