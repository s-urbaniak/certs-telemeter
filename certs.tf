resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm   = "${tls_private_key.ca.algorithm}"
  private_key_pem = "${tls_private_key.ca.private_key_pem}"

  subject {
    common_name = "telemeter"
  }

  is_ca_certificate     = true
  validity_period_hours = "26280" // 3 years, should be enough

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}

resource "tls_private_key" "shared_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "shared_key" {
  key_algorithm   = "${tls_private_key.shared_key.algorithm}"
  private_key_pem = "${tls_private_key.shared_key.private_key_pem}"

  subject {
    common_name = "telemeter-cluster.telemeter.svc"
  }

  dns_names = [
    "telemeter-cluster.telemeter.svc",
    "telemeter-cluster.telemeter.svc.cluster.local",
  ]
}

resource "tls_locally_signed_cert" "shared_key" {
  cert_request_pem = "${tls_cert_request.shared_key.cert_request_pem}"

  ca_key_algorithm   = "${tls_self_signed_cert.ca.key_algorithm}"
  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = "26280"

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "local_file" "tls_crt" {
  content  = "${tls_locally_signed_cert.shared_key.cert_pem}${tls_self_signed_cert.ca.cert_pem}"
  filename = "tls.crt"
}

resource "local_file" "tls_key" {
  content  = "${tls_private_key.shared_key.private_key_pem}"
  filename = "tls.key"
}
