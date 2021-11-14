data "kustomization_overlay" "resources" {
  resources = [
    "${path.module}/base"
  ]

  patches {
    target = {
      kind = "Ingress"
      name = "grafana"
    }
    patch = <<-EOF
    - op: replace
      path: /spec/rules/0/host
      value: grafana.${var.domain}
    EOF
  }
  patches {
    target = {
      kind = "Deployment"
      name = "grafana"
    }
    patch = <<-EOF
    - op: add
      path: /spec/template/spec/containers/0/env/-
      value:
        name: GF_SERVER_DOMAIN
        value: grafana.${var.domain}
    - op: add
      path: /spec/template/spec/containers/0/env/-
      value:
        name: GF_SERVER_ROOT_URL
        value: https://grafana.${var.domain}
    EOF
  }
}

# first loop through resources in ids_prio[0]
resource "kustomization_resource" "p0" {
  for_each = data.kustomization_overlay.resources.ids_prio[0]
  manifest = data.kustomization_overlay.resources.manifests[each.value]
}

# then loop through resources in ids_prio[1]
# and set an explicit depends_on on kustomization_resource.p0
resource "kustomization_resource" "p1" {
  for_each   = data.kustomization_overlay.resources.ids_prio[1]
  manifest   = data.kustomization_overlay.resources.manifests[each.value]
  depends_on = [kustomization_resource.p0]
}

# finally, loop through resources in ids_prio[2]
# and set an explicit depends_on on kustomization_resource.p1
resource "kustomization_resource" "p2" {
  for_each   = data.kustomization_overlay.resources.ids_prio[2]
  manifest   = data.kustomization_overlay.resources.manifests[each.value]
  depends_on = [kustomization_resource.p1]
}
