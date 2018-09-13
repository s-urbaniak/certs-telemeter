provider "kubernetes" {
  config_path = "${var.k8s_config_path}"
}

resource "kubernetes_secret" "telemeter-shared" {
  metadata {
    name = "telemeter-shared"
  }

  data {
    "tls.crt" = "${tls_locally_signed_cert.shared_key.cert_pem}${tls_self_signed_cert.ca.cert_pem}"
    "tls.key" = "${tls_private_key.shared_key.private_key_pem}"
  }
}
