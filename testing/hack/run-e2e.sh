#!/bin/bash
set -xe

export NEXUS_URL=$1
export NEXUS_USERNAME=$2
export NEXUS_PASSWORD=$3
export CASE_PARAM=$4
# DEVOPS-44489: optional 5th arg, "domain:ip[,domain:ip...]" -- the ingress
# hostname(s) this run's NEXUS_URL (and any proxy/publish target pytest shells
# out to via mvn/npm) needs to resolve. run-test's own container is non-root
# (PSA-restricted, uid 65532) so it can't write /etc/hosts; bdd's in-process
# fake resolver (steps/dns) already covers the framework's own HTTP client
# (network.feature's "已添加域名解析" step feeds it), but mvn/npm are child
# subprocesses os.system()'d from pytest -- those need OS-level resolution.
# nss_wrapper (LD_PRELOAD + NSS_WRAPPER_HOSTS) overrides glibc's NSS hosts
# lookup for this process tree without touching the real /etc/hosts, same
# fix proven for gitlab-chart's git/git-lfs subprocess (testing/steps/
# gitlab_lfs.go's gitHostEnv, DEVOPS-44461 2026-07-20) -- mvn (JVM) and npm
# (Node) both resolve via glibc getaddrinfo by default on Linux, so no
# GODEBUG=netdns=cgo override is needed here (that's only for Go binaries,
# which default to the pure-Go resolver that ignores nss_wrapper).
EXTRA_HOSTS=$5
if [ -n "${EXTRA_HOSTS:-}" ] && [ -f /usr/lib/x86_64-linux-gnu/libnss_wrapper.so ]; then
  NSS_HOSTS_FILE=$(mktemp)
  IFS=',' read -ra HOST_PAIRS <<< "$EXTRA_HOSTS"
  for pair in "${HOST_PAIRS[@]}"; do
    domain="${pair%%:*}"
    ip="${pair##*:}"
    echo "${ip} ${domain}" >> "$NSS_HOSTS_FILE"
  done
  export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libnss_wrapper.so
  export NSS_WRAPPER_HOSTS="$NSS_HOSTS_FILE"
fi

cd nexus-e2e
python -m pytest --alluredir ../allure-results $CASE_PARAM
