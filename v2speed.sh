#!/bin/bash

echo_info() {
  echo -e "\033[1;32m[INFO]\033[0m $1"
}
echo_error() {
  echo -e "\033[1;31m[ERROR]\033[0m $1"
  exit 1
}

apt-get update; apt-get install curl socat git nload -y

if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh || echo_error "Docker installation failed."
else
  echo_info "Docker is already installed."
fi

rm -r Marzban-node

git clone https://github.com/Gozargah/Marzban-node

rm -r /var/lib/marzban-node

mkdir /var/lib/marzban-node

rm ~/Marzban-node/docker-compose.yml

cat <<EOL > ~/Marzban-node/docker-compose.yml
services:
  marzban-node:
    image: gozargah/marzban-node:latest
    restart: always
    network_mode: host
    environment:
      SSL_CERT_FILE: "/var/lib/marzban-node/ssl_cert.pem"
      SSL_KEY_FILE: "/var/lib/marzban-node/ssl_key.pem"
      SSL_CLIENT_CERT_FILE: "/var/lib/marzban-node/ssl_client_cert.pem"
      SERVICE_PROTOCOL: "rest"
    volumes:
      - /var/lib/marzban-node:/var/lib/marzban-node
EOL

rm /var/lib/marzban-node/ssl_client_cert.pem

cat <<EOL > /var/lib/marzban-node/ssl_client_cert.pem
-----BEGIN CERTIFICATE-----
MIIEnDCCAoQCAQAwDQYJKoZIhvcNAQENBQAwEzERMA8GA1UEAwwIR296YXJnYWgw
IBcNMjUwMTIwMTkyODI4WhgPMjEyNDEyMjcxOTI4MjhaMBMxETAPBgNVBAMMCEdv
emFyZ2FoMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAo41nel09RNkC
KBptaTUE9P2JT8Rl3YovXGfxNd2u7Y8JgK0TsqHq00qgofA4c8TR+rtDHmEwH5jg
EwKW6ypvq46Q2tM5/xbNdo9q9dyvo4IGYIabI4o2Z0fCk/Ukx3QuOUgHf2VCpG+5
+SaXbkh+3x8a4dHF/sYjXJxrP86+cJcUft7hCi8GIrV6enaXT7j0lxS+hTEDdXif
3bcfRWWPBDFL/oahi57w7cF86vREStt4dI7N7ytTqRS8oPQ4tEpeI/9wuHaY7wgm
7kz9TBY8/UjXfnQfiTdWt/GJpHvwQrd8vbeaA12jrPhxvhUDSI65gtLQrw40MJOP
bu78Wcvbvom/7Aa3tbKXT9+fIaxl4FqFw2quq3L/DkimW4L5XBz6wN1/gp4sdMlV
VFtaC04zbM/pAGUaNHGobCMv2aVidC1ikpeTl2+W9GML5kzwFr5/labXIhjiwKKr
zGpDk6uwnoezuM/YbwY9VIcWM4XDw6Aq3zp0Q4nxIROeYv5x9P6hIBkY54hKI8xl
rSeZsUW1zer7N064WgJLZ7msqdeh252YSa9MXfZC9tXR6xyZvto8wTAu5LvJnxJI
9FO0+jsDniXnwPsGtukq7YAkLv6H7u/5DxTqW1hhDnCAWRUwiHcRzLg8St0NPrcv
YQrecNTelGJwIjrWsNJcDbP1xxcKjRkCAwEAATANBgkqhkiG9w0BAQ0FAAOCAgEA
SZ9RcU1QWzbQQoVORHXCBqIR07jh/QwmiiFE0Oqn2Qn//jQvVYHxbS47+Qy4sPrM
dF2HMp0n0+ZfmzXKnGWLx5Dp5tqJrAA2t624k+suHDN/JqP9T6t6haN5EJq675yS
88NO2tHzuqRcCJpfX9cl2qhML2uhyeHdu//MYx13msiRna0AvpMtALk1EjnUNaLM
L+kWmLvu8JlI19XjoCQkHAk4faKeZKGnaP01mda6/i/z8akgaNy024NsAx3VsS/n
0eiGh2snUCqfA/2RooX7gHt3timoirgZhpZK+OhxzyBc5NXTabJUUIaWNt3ExZ4u
1unIX9w8KHDph5AXkffHwwvN/d7CYRYvJTz8951j8FwX7H5zbnSnkL0Ug2U2BofO
rERu07r3lf/ojoGNDwMCR/doXi4W4iGZ1cjNdQoLaY2wK+L9c6KkszrVv0jrgcS1
lXSSBc99QhBmEGM2JjfxUFV1ffpexYHwlC7RrDB1juCJffHaISKJjyd3hUk29Oce
92KhoizGjz5HEKmP1iJgR+Hs4F80YJORSy7p7IEOezPxux9bSS1bd+5oJ2ILg9do
4hxXhX2BeFPBhQrGQTBM6gUp6kj/VQSuAXiE0zwaTESIglUmqLvps22kzFFPf8AQ
PLLYHDqvJzTcz+HtXm0VmhVs6WQEdgDxj/std2dOowY=
-----END CERTIFICATE-----
EOL

cd ~/Marzban-node
docker compose up -d

echo_info "Finalizing UFW setup..."

ufw allow 22
ufw allow 80
ufw allow 2053
ufw allow 62050
ufw allow 62051

ufw --force enable
ufw reload

curl -sSL https://raw.githubusercontent.com/Tozuck/Node_monitoring/main/node_monitor.sh | bash
