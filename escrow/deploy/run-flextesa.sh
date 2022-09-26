#!/bin/sh
# Script to run a flextesa Tezos sandbox
# https://tezos.gitlab.io/flextesa/

IMAGE=oxheadalpha/flextesa:20220510
SCRIPT=jakartabox

docker run --rm  --name flextesa --detach -p 20000:20000 -e block_time=2 -e flextesa_node_cors_origin='*' "$IMAGE" "$SCRIPT" start