#!/usr/bin/env bash
# DEVOPS-44489: ported byte-for-byte (functions unchanged below) from
# gitlab-ce-operator's migration branch (alauda-devops-toolchain/gitlab-ce-operator,
# testing/script/prepare-cluster.sh) -- same shared ctyun-vm-integration-test harness,
# same throwaway single-node-VM ingress/RWX gaps, already proven green there. Driver
# direction (2026-07-23): the migrated e2e's case scope must match the ORIGINAL github
# pipeline exactly (it used vcluster-integration-test, which synced real ingress from
# the host) -- so network.feature's ingress scenarios must actually pass here, not be
# tagged @e2e to route around the gap. See .tekton/integration-test.yaml's `deploy`
# param for how this gets invoked.
#
# DEVOPS-44461 (original gitlab-ce-operator ticket, comments below unchanged): prepare
# the throwaway ctyun-vm k3s cluster for the gitlab-chart smoke
# suite. Best-effort by DESIGN -- deploy has no onError:continue, and a hard failure here
# would SKIP run-test entirely (runAfter) and burn the whole VM cycle with zero test
# signal, which is worse than a patch silently not helping. So every step is allowed to
# fail and the script always returns 0.
#
# Env: SOURCE_PATH (workspace source root, required); KUBECTL_IMAGE (image for the on-VM
# pull-probe, required). KUBECONFIG is derived from SOURCE_PATH.
set -ux
: "${SOURCE_PATH:?SOURCE_PATH required}"
export KUBECONFIG="${SOURCE_PATH}/.git/ctyun-vm/kubeconfig"

# ---- RWX storage for the HA smoke scenario ----------------------------------------------
# (rationale in testdata/resources/rwx-hostpath.yaml) A static hostPath PV advertised as
# ReadWriteMany + a no-provisioner `nfs` StorageClass: on the single-node VM hostPath is
# shared RW by all pods, a real RWX equivalent WITHOUT needing an NFS client on the node.
rwx_storage() {
  kubectl apply -f "${SOURCE_PATH}/testing/testdata/resources/rwx-hostpath.yaml" || echo "WARN: rwx-hostpath apply failed"
  # loop-generate the RWX PV pool (RWX_PV_POOL, default 40) instead of writing N PVs out;
  # PVs advertise all access modes (RWO+RWX+ROX) so any PVC (uploads RWX, gitaly/redis RWO) binds.
  __pool="${RWX_PV_POOL:-40}"
  { __i=0; while [ "$__i" -lt "$__pool" ]; do __n=$(printf '%02d' "$__i"); cat <<PVEOF
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gitlab-rwx-${__n}
  labels:
    pool: nfs-rwx
spec:
  capacity:
    storage: 10Gi
  storageClassName: nfs
  accessModes: [ReadWriteOnce, ReadWriteMany, ReadOnlyMany]
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /tmp/gitlab-rwx-${__n}
    type: DirectoryOrCreate
PVEOF
  __i=$((__i+1)); done; } | kubectl apply -f - || echo "WARN: PV pool apply failed"
  # make nfs the sole default SC: bdd's <storage-class> returns the default first, and
  # local-path (RWO) can't back the shared uploads PVC. Drop local-path's default flag.
  kubectl patch storageclass local-path -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}' 2>/dev/null || true
  kubectl patch storageclass nfs -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' 2>/dev/null || true
  kubectl get storageclass || true
  echo "nfs RWX PVs: $(kubectl get pv -l pool=nfs-rwx --no-headers 2>/dev/null | wc -l)"
}

# ---- make the ingress controller publish a status IP ------------------------------------
# bdd's StepExistIngressController creates a CLASSLESS probe Ingress and polls its
# .status.loadBalancer.ingress[0].ip for 2min; the baked controller neither watches
# classless Ingresses nor publishes an address, so ha(135)/https(211) time out. Annotate
# the nginx IngressClass default + add --publish-status-address=<node ip> +
# --watch-ingress-without-class=true, then roll out. Diagnostics land in deploy-diag.log
# (uploaded with allure-results).
fix_ingress() {
  local NS=ingress-nginx DIAG NODE_IP ICLASS CDEPLOY CARGS SVC
  DIAG="${SOURCE_PATH}/testing/deploy-diag.log"
  mkdir -p "$(dirname "${DIAG}")" 2>/dev/null || true
  : > "${DIAG}" 2>/dev/null || true

  echo "=== live cluster state before run-test (diagnostic) ==="
  kubectl get pods -A || true
  kubectl get ingressclass || true

  NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null || true)
  echo "VM node InternalIP: ${NODE_IP:-<none>}"
  SVC=$(kubectl get svc -n "${NS}" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null | tr ' ' '\n' | grep -E 'controller$' | head -1 || true)
  ICLASS=$(kubectl get ingressclass -o jsonpath='{.items[*].metadata.name}' 2>/dev/null | tr ' ' '\n' | grep -iE 'nginx' | head -1 || true)
  echo "nginx IngressClass: ${ICLASS:-<none>} / controller Service: ${NS}/${SVC:-<not found>}"
  [ -n "${ICLASS:-}" ] && kubectl annotate ingressclass "${ICLASS}" ingressclass.kubernetes.io/is-default-class=true --overwrite || echo "WARN: default-class annotate skipped/failed"

  CDEPLOY=$(kubectl get deploy -n "${NS}" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null | tr ' ' '\n' | grep -E 'controller$' | head -1 || true)
  echo "ingress-nginx controller Deployment: ${NS}/${CDEPLOY:-<not found>}"
  if [ -n "${CDEPLOY:-}" ] && [ -n "${NODE_IP:-}" ]; then
    CARGS=$(kubectl get deploy "${CDEPLOY}" -n "${NS}" -o jsonpath='{.spec.template.spec.containers[0].args}' 2>/dev/null || true)
    case "${CARGS}" in
      *publish-status-address*) echo "controller already has --publish-status-address, skipping arg patch" ;;
      *) kubectl patch deploy "${CDEPLOY}" -n "${NS}" --type=json -p "[{\"op\":\"add\",\"path\":\"/spec/template/spec/containers/0/args/-\",\"value\":\"--publish-status-address=${NODE_IP}\"},{\"op\":\"add\",\"path\":\"/spec/template/spec/containers/0/args/-\",\"value\":\"--watch-ingress-without-class=true\"}]" || echo "WARN: controller args patch failed" ;;
    esac
    kubectl rollout status deploy/"${CDEPLOY}" -n "${NS}" --timeout=120s || echo "WARN: controller rollout not complete"
  fi
  { echo "=== deploy-diag: ingressclasses ==="; kubectl get ingressclass -o yaml; echo "=== controller deploy args ==="; kubectl get deploy -n "${NS}" -o jsonpath='{range .items[*]}{.metadata.name}{": "}{.spec.template.spec.containers[0].args}{"\n"}{end}'; echo; echo "=== ingress-nginx pods ==="; kubectl get pods -n "${NS}" -o wide; echo "=== ingress-nginx svc ==="; kubectl get svc -n "${NS}" -o wide; } >> "${DIAG}" 2>&1 || true
}

# ---- reproduce the CNG image pull directly on the VM k3s ---------------------------------
# The shared-secrets Helm pre-install hook has failed live with "image can't be pulled" for
# this same kubectl image on the VM's own k3s (a different net/auth path than this step,
# which runs on edge-build). Reproduce the pull here so a real VM-side gap surfaces with a
# clear reason instead of a silent 5-minute helm timeout.
pull_probe() {
  : "${KUBECTL_IMAGE:?KUBECTL_IMAGE required}"
  echo "=== reproducing the CNG image pull directly on the VM k3s ==="
  kubectl delete pod deploy-step-pull-probe -n default --ignore-not-found --wait=true || true
  kubectl run deploy-step-pull-probe -n default --restart=Never --image="${KUBECTL_IMAGE}" --command -- sleep 30 || echo "WARN: probe pod create failed"
  for i in $(seq 1 18); do
    phase=$(kubectl get pod deploy-step-pull-probe -n default -o jsonpath='{.status.phase}' 2>/dev/null || true)
    echo "pull-probe phase (poll $i): ${phase:-<none>}"
    [ "${phase}" = "Running" ] && { echo "PULL-PROBE OK: image pulled and running"; break; }
    sleep 5
  done
  kubectl describe pod deploy-step-pull-probe -n default 2>&1 | tail -30 || true
  kubectl delete pod deploy-step-pull-probe -n default --ignore-not-found || true
}

# ---- also make port 80/443 reachable on the node IP + belt-and-suspenders status IP ----
# --publish-status-address (above) makes the readiness probe pass; this additionally sets
# the controller Service externalIPs to the node IP so http(s)://<node ip>:80/443 routes to
# ingress-nginx for the ha/https scenarios, and (Service flipped to LoadBalancer so the
# status subresource is writable) patches status.loadBalancer.ingress directly as a second
# path to the same IP. Kept from the proven-green config; NodePort access is unaffected.
publish_service_status() {
  local NS=ingress-nginx SVC NODE_IP ip i
  NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null || true)
  SVC=$(kubectl get svc -n "${NS}" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null | tr ' ' '\n' | grep -E 'controller$' | head -1 || true)
  [ -n "${SVC:-}" ] && [ -n "${NODE_IP:-}" ] || { echo "WARN: no ingress controller Service or node IP -- skipping externalIPs patch"; return 0; }
  kubectl patch svc "${SVC}" -n "${NS}" --type=merge -p "{\"spec\":{\"externalIPs\":[\"${NODE_IP}\"]}}" || echo "WARN: externalIPs patch failed"
  kubectl patch svc "${SVC}" -n "${NS}" --type=merge -p "{\"spec\":{\"type\":\"LoadBalancer\"}}" || echo "WARN: type=LoadBalancer patch failed"
  kubectl patch svc "${SVC}" -n "${NS}" --type=merge --subresource=status -p "{\"status\":{\"loadBalancer\":{\"ingress\":[{\"ip\":\"${NODE_IP}\"}]}}}" || echo "WARN: status.loadBalancer.ingress patch failed"
  echo "=== verifying a throwaway Ingress gets a status IP (mirrors StepExistIngressController) ==="
  kubectl create ingress deploy-step-ingress-probe -n default --rule="deploy-step-probe.example.com/=example-service:80" --dry-run=client -o yaml 2>/dev/null | kubectl apply -f - || echo "WARN: probe ingress create failed"
  for i in $(seq 1 12); do
    ip=$(kubectl get ingress deploy-step-ingress-probe -n default -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
    [ -n "${ip}" ] && { echo "PROBE OK: ingress status IP = ${ip}"; break; }
    echo "probe wait $i (no status IP yet)"; sleep 5
  done
  kubectl delete ingress deploy-step-ingress-probe -n default --ignore-not-found || true
}


rwx_storage
fix_ingress
publish_service_status
exit 0
