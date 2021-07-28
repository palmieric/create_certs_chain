# Certificate Chain Creator

## Usage

``` bash
git clone https://github.com/palmieric/create_certs_chain.git
cd create_certs_chain/root/tls

make all
```

It will generate

- Root CA certificate and key (certs/cacert.pem, private/cakey.pem)
- Intermediate CA certificate and key (intermediate/certs/cacert.pem, intermediate/private/cakey.pem)
- Server certificate and key signed by Root CA (server/certs/cacert.pem, server/private/cakey.pem)
- Client certificate and key signed by Intermediate CA (client/client.pem, client/client.key)
- Certificate chains

To verify the resulted certificate

``` bash
make verify
```

To restart from scratch

``` bash
make clean
```

The target available in the Makefile are

- root
- intermediate
- server
- client
- chain
- verify
