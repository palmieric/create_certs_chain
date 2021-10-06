clean:
	rm -f client/client.*
	rm -f *_chain.pem
	rm -f certs/*.pem
	rm -f private/cakey.pem
	rm -f {intermediate,server}/{certs,csr,private}/*.{pem,srl,key}
	rm -f index.*
	rm -f mypass.enc
	rm -Rf nginx_certs/
	touch index.txt
	echo '01' > serial

passphrase mypass.enc:
	openssl rand -hex 8 > mypass.enc
root certs/cacert.pem: mypass.enc
	openssl genrsa -des3 -passout file:mypass.enc -out private/cakey.pem 4096
	openssl req -new -x509 -days 3650 -passin file:mypass.enc -config openssl.cnf -extensions v3_ca -key private/cakey.pem -out certs/cacert.pem
	openssl x509 -in certs/cacert.pem -out certs/cacert.pem -outform PEM

intermediate intermediate/certs/intermediate.cacert.pem: certs/cacert.pem
	openssl genrsa -des3 -passout file:mypass.enc -out intermediate/private/intermediate.cakey.pem 4096
	openssl req -new -sha256 -config intermediate/openssl.cnf -passin file:mypass.enc  -key intermediate/private/intermediate.cakey.pem -out intermediate/csr/intermediate.csr.pem
	openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 3650 -notext -batch -passin file:mypass.enc -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cacert.pem
	openssl x509 -in intermediate/certs/intermediate.cacert.pem -out intermediate/certs/intermediate.cacert.pem -outform PEM

server server/certs/server.cert.pem: certs/cacert.pem
	openssl genrsa -des3 -passout file:mypass.enc -out server/private/server.key 4096
	openssl req -new -sha256 -config intermediate/openssl.cnf -passin file:mypass.enc  -key server/private/server.key -out server/csr/server.csr.pem
	openssl ca -config openssl.cnf -days 3650 -notext -batch -passin file:mypass.enc -in server/csr/server.csr.pem -out server/certs/server.cert.pem
	openssl x509 -in server/certs/server.cert.pem -out server/certs/server.cert.pem -outform PEM


client client/client.pem: intermediate
	openssl genrsa -out client/client.key 4096
	openssl req -new -subj '/CN=test' -key client/client.key -out client/client.req
	openssl x509 -req -in client/client.req -CA intermediate/certs/intermediate.cacert.pem -CAkey intermediate/private/intermediate.cakey.pem -CAcreateserial -out client/client.pem -days 500 -sha256 -passin file:./mypass.enc
	openssl x509 -in client/client.pem -out client/client.pem -outform PEM


chain full_chain.pem half_chain.pem: client/client.pem intermediate/certs/intermediate.cacert.pem certs/cacert.pem
	cat client/client.pem intermediate/certs/intermediate.cacert.pem certs/cacert.pem > full_chain.pem
	cat intermediate/certs/intermediate.cacert.pem certs/cacert.pem > half_chain.pem

verify: client/client.pem intermediate/certs/intermediate.cacert.pem certs/cacert.pem server/certs/server.cert.pem
	openssl verify -CAfile half_chain.pem client/client.pem
	openssl verify -CAfile half_chain.pem server/certs/server.cert.pem
	openssl verify -CAfile certs/cacert.pem intermediate/certs/intermediate.cacert.pem

nginx-certs: 
	mkdir nginx_certs
	cp full_chain.pem nginx_certs
	cp certs/cacert.pem nginx_certs
	cp client/client.key nginx_certs
	cp server/certs/server.cert.pem nginx_certs
	cp server/private/server.key nginx_certs

all: root intermediate server client chain nginx-certs