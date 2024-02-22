package main

import (
	"crypto/tls"
	"log"
	"net/http"
)

const (
	port        = ":8443"
	reponsebody = "Hello, TLS"
)

func main() {
	cert, err := tls.LoadX509KeyPair("certs/server.crt", "certs/server.key")
	if err != nil {
		log.Fatalf("Failed to load X509 key pair: %v", err)
	}

	config := &tls.Config{
		Certificates: []tls.Certificate{cert},
	}

	router := http.NewServeMux()
	router.HandleFunc("/", handleRequst)

	server := &http.Server{
		Addr:      port,
		Handler:   router,
		TLSConfig: config,
	}

	log.Printf("listening on %s", port)
	err = server.ListenAndServeTLS("", "")
	if err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}

}
func handleRequst(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}
