#!/bin/zsh

#CLEAN PREVIOUS RUN
rm -f client.key client.req certs/cacert.pem private/cakey.pem intermediate/private/intermediate.cakey.pem intermediate/csr/intermediate.csr.pem intermediate/certs/intermediate.cacert.pem intermediate/certs/intermediate.cacert.srl index.*

touch index.txt

#GENERATE ROOT CA PRIVATE KEY
echo GENERATE ROOT CA PRIVATE KEY
openssl genrsa -des3 -passout file:mypass.enc -out private/cakey.pem 4096

#CREATE ROOT CA CERT
echo CREATE ROOT CA CERT
openssl req -new -x509 -days 3650 -passin file:mypass.enc -config openssl.cnf -extensions v3_ca -key private/cakey.pem -out certs/cacert.pem

#CONVERT THE FORMAT TO PEM
openssl x509 -in certs/cacert.pem -out certs/cacert.pem -outform PEM

#GENERATE INTERMEDIATE CA KEY
echo GENERATE INTERMEDIATE CA KEY
openssl genrsa -des3 -passout file:mypass.enc -out intermediate/private/intermediate.cakey.pem 4096

#CREATE CA CSR
echo CREATE CA CSR
openssl req -new -sha256 -config intermediate/openssl.cnf -passin file:mypass.enc  -key intermediate/private/intermediate.cakey.pem -out intermediate/csr/intermediate.csr.pem

#SIGN AND GENERATE CA INTERMEDIATE CERT
echo SIGN AND GENERATE CA INTERMEDIATE CERT
openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 3650 -notext -batch -passin file:mypass.enc -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cacert.pem

#GENERATE CLIENT KEY
echo openssl genrsa -out client.key 4096
openssl genrsa -out client.key 4096

#GENERATE CLIENT KEY SIGNATURE REQUEST
echo GENERATE CLIENT KEY SIGNATURE REQUEST
openssl req -new -subj '/CN=test' -key client.key -out client.req

#SIGN THE REQUEST USING INTERMEDIATE CERTIFICATE
echo SIGN THE REQUEST USING INTERMEDIATE CERTIFICATE
openssl x509 -req -in client.req -CA intermediate/certs/intermediate.cacert.pem -CAkey intermediate/private/intermediate.cakey.pem -CAcreateserial -out client.pem -days 500 -sha256 -passin file:./mypass.enc
