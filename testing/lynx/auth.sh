#!/usr/bin/env bash

_auth_login_with_password() (
  set +x
  set -o pipefail

  local api_url=${API_URL%/}
  local request_timeout=${LYNX_HTTP_TIMEOUT:-30}
  local workdir
  workdir=$(mktemp -d) || fatal "could not create authentication workspace"
  trap 'rm -rf -- "$workdir"' EXIT

  local cookie_jar=$workdir/cookies
  local public_key=$workdir/public.pem
  local curl_options=(
    --silent
    --show-error
    --fail
    --insecure
    --connect-timeout "$request_timeout"
    --max-time "$request_timeout"
    --cookie "$cookie_jar"
    --cookie-jar "$cookie_jar"
  )
  local login_json auth_url auth_query authorize_json request_id
  local pubkey_json password_payload encrypted_password credentials_json
  local local_login_json redirect_url callback_query code state callback_json token

  login_json=$(curl "${curl_options[@]}" --get \
    --data-urlencode "redirect_uri=$api_url/console-platform" \
    "$api_url/console-platform/api/v1/token/login" 2>/dev/null) \
    || fatal "ACP token login request failed"
  auth_url=$(printf '%s' "$login_json" | jq -er '.auth_url | select(type == "string" and length > 0)' 2>/dev/null) \
    || fatal "ACP token login response is invalid"
  auth_query=${auth_url#*\?}
  [[ $auth_query != "$auth_url" ]] || fatal "ACP token login response is invalid"

  authorize_json=$(curl "${curl_options[@]}" \
    "$api_url/dex/api/v1/authorize?$auth_query" 2>/dev/null) \
    || fatal "ACP Dex authorization request failed"
  request_id=$(printf '%s' "$authorize_json" | jq -er '.req | select(type == "string" and length > 0)' 2>/dev/null) \
    || fatal "ACP Dex authorization response is invalid"

  pubkey_json=$(curl "${curl_options[@]}" "$api_url/dex/pubkey" 2>/dev/null) \
    || fatal "ACP Dex public key request failed"
  printf '%s' "$pubkey_json" | jq -er '.pubkey | select(type == "string" and length > 0)' \
    >"$public_key" 2>/dev/null || fatal "ACP Dex public key response is invalid"
  password_payload=$(printf '%s' "$pubkey_json" | jq -cer --arg password "$PASSWORD" \
    '{ts: .ts, password: $password} | select(.ts != null)' 2>/dev/null) \
    || fatal "ACP Dex public key response is invalid"
  encrypted_password=$(printf '%s' "$password_payload" \
    | openssl pkeyutl -encrypt -pubin -inkey "$public_key" \
      -pkeyopt rsa_padding_mode:pkcs1 \
    | openssl base64 -A) || fatal "ACP password encryption failed"
  [[ -n $encrypted_password ]] || fatal "ACP password encryption failed"

  credentials_json=$(jq -cn --arg account "$USERNAME" --arg password "$encrypted_password" \
    '{account: $account, password: $password}') \
    || fatal "ACP login request could not be created"
  local_login_json=$(printf '%s' "$credentials_json" | curl "${curl_options[@]}" \
    --request POST --header 'Content-Type: application/json' --data-binary @- \
    "$api_url/dex/api/v1/authorize/local?req=$request_id" 2>/dev/null) \
    || fatal "ACP identity provider login failed"
  redirect_url=$(printf '%s' "$local_login_json" | jq -er \
    '.redirect_url | select(type == "string" and length > 0)' 2>/dev/null) \
    || fatal "ACP identity provider response is invalid"
  callback_query=${redirect_url#*\?}
  [[ $callback_query != "$redirect_url" ]] || fatal "ACP identity provider response is invalid"
  code=$(printf '%s' "$callback_query" | tr '&' '\n' | sed -n 's/^code=//p' | head -1)
  state=$(printf '%s' "$callback_query" | tr '&' '\n' | sed -n 's/^state=//p' | head -1)
  [[ -n $code && -n $state ]] || fatal "ACP identity provider response is invalid"

  callback_json=$(curl "${curl_options[@]}" \
    "$api_url/console-platform/api/v1/token/callback?code=$code&state=$state" 2>/dev/null) \
    || fatal "ACP token callback request failed"
  token=$(printf '%s' "$callback_json" | jq -er \
    '.id_token | select(type == "string" and length > 0)' 2>/dev/null) \
    || fatal "ACP token callback response is invalid"
  printf '%s' "$token"
)

resolve_access_token() {
  set +x
  if [[ -n ${TOKEN:-} ]]; then
    printf '%s' "$TOKEN"
    return
  fi

  [[ -n ${USERNAME:-} && -n ${PASSWORD:-} ]] \
    || fatal "authentication requires TOKEN or both USERNAME and PASSWORD"
  require_env API_URL
  require_command curl
  require_command jq
  require_command openssl
  require_positive_integer LYNX_HTTP_TIMEOUT "${LYNX_HTTP_TIMEOUT:-30}"
  _auth_login_with_password
}

write_proxy_kubeconfig() {
  set +x
  local destination=$1
  local token=$2
  local api_url=${API_URL%/}
  local temporary=${destination}.tmp.$$

  require_env API_URL
  require_env REGION_NAME
  require_command jq
  umask 077
  trap 'rm -f -- "$temporary"' RETURN
  jq -n --arg server "$api_url/kubernetes/$REGION_NAME" --arg token "$token" '
    {
      apiVersion: "v1",
      kind: "Config",
      clusters: [{name: "target", cluster: {server: $server}}],
      users: [{name: "target", user: {token: $token}}],
      contexts: [{name: "target", context: {cluster: "target", user: "target"}}],
      "current-context": "target"
    }
  ' >"$temporary" || fatal "could not write proxy kubeconfig"
  chmod 0600 "$temporary" || fatal "could not protect proxy kubeconfig"
  mv -f -- "$temporary" "$destination" || fatal "could not install proxy kubeconfig"
  trap - RETURN
}

write_bdd_config() {
  set +x
  local destination=$1
  local token=$2
  local api_url=${API_URL%/}
  local temporary=${destination}.tmp.$$

  require_env API_URL
  require_env REGION_NAME
  require_command jq
  umask 077
  trap 'rm -f -- "$temporary"' RETURN
  jq -n --arg base_url "$api_url" --arg token "$token" --arg cluster "$REGION_NAME" '
    {acp: {baseUrl: $base_url, token: $token, cluster: $cluster}}
  ' >"$temporary" || fatal "could not write BDD configuration"
  chmod 0600 "$temporary" || fatal "could not protect BDD configuration"
  mv -f -- "$temporary" "$destination" || fatal "could not install BDD configuration"
  trap - RETURN
}
