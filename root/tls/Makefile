clean:
	rm -f client/client.*
	rm -f *_chain.pem
	rm -f certs/*.pem
	rm -f private/cakey.pem
	rm -f intermediate/certs/*.{pem,srl}
	rm -f intermediate/{csr,private}/*.pem
	rm -f index.*
	touch index.txt
	echo '01' > serial

root: clean
	openssl genrsa -des3 -passout file:mypass.enc -out private/cakey.pem 4096
	openssl req -new -x509 -days 3650 -passin file:mypass.enc -config openssl.cnf -extensions v3_ca -key private/cakey.pem -out certs/cacert.pem
	openssl x509 -in certs/cacert.pem -out certs/cacert.pem -outform PEM

intermediate: certs/cacert.pem
	openssl genrsa -des3 -passout file:mypass.enc -out intermediate/private/intermediate.cakey.pem 4096
	openssl req -new -sha256 -config intermediate/openssl.cnf -passin file:mypass.enc  -key intermediate/private/intermediate.cakey.pem -out intermediate/csr/intermediate.csr.pem
	openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 3650 -notext -batch -passin file:mypass.enc -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cacert.pem

client: intermediate/certs/intermediate.cacert.pem
	openssl genrsa -out client/client.key 4096
	openssl req -new -subj '/CN=test' -key client/client.key -out client/client.req
	openssl x509 -req -in client/client.req -CA intermediate/certs/intermediate.cacert.pem -CAkey intermediate/private/intermediate.cakey.pem -CAcreateserial -out client/client.pem -days 500 -sha256 -passin file:./mypass.enc

chain:
	cat client/client.pem intermediate/certs/intermediate.cacert.pem private/cakey.pem > full_chain.pem
	cat intermediate/certs/intermediate.cacert.pem private/cakey.pem > half_chain.pem

all: root intermediate client chain