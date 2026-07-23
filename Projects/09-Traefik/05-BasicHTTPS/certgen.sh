mkdir -p certs && openssl req -x509 -nodes -days 1 -newkey rsa:2048 \
  -keyout certs/localhost-cert.key \
  -out certs/localhost-cert.crt \
  -subj "/CN=*.localhost" \
  -addext "subjectAltName=DNS:localhost,DNS:*.localhost"
