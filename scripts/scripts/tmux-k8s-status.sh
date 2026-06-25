#!/bin/bash
# tmux-k8s-status.sh — k8s context for tmux status bar
CTX=$(kubectl config current-context 2>/dev/null)
[[ -z "$CTX" ]] && exit 0

# Shorten EKS ARN-style contexts: extract cluster name after last /
CTX="${CTX##*/}"

NS=$(kubectl config view --minify --output 'jsonpath={.contexts[0].context.namespace}' 2>/dev/null)
[[ -n "$NS" ]] && CTX="$CTX($NS)"

echo "󱃾 $CTX"
