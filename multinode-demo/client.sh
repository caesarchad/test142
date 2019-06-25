#!/usr/bin/env bash
set -e
PATH=$PWD/bin:$PATH
here=$(dirname "$0")
# shellcheck source=multinode-demo/common.sh
source "$here"/common.sh

usage() {
  if [[ -n $1 ]]; then
    echo "$*"
    echo
  fi
  echo "usage: $0 [extra args]"
  echo
  echo " Run bench-tps "
  echo
  echo "   extra args: additional arguments are pass along to solana-bench-tps"
  echo
  exit 1
}

if [[ -z $1 ]]; then # default behavior
  solana-bench-tps \
    --network 127.0.0.1:8001 \
    --drone 127.0.0.1:9900 \
    --duration 90 \
    --tx_count 50000 \

else
  solana-bench-tps "$@"
fi