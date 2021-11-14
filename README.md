helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm template tempo grafana/tempo-distributed \
  --values values/tempo.yaml \
  --namespace monitoring \
  --output-dir base
helm template grafana grafana/loki \
  --namespace monitoring \
  --output-dir base
helm template grafana grafana/grafana \
  --values values/grafana.yaml \
  --namespace monitoring \
  --output-dir base
