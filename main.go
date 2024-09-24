package main

import (
	"FlutterBackend/initializers"
	"FlutterBackend/routes"
	"errors"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
	"net/http"
)

func init() {
	initializers.LoadEnvVariables()
	initializers.ConnectToDb()
	initializers.SyncDatabase()
}

func main() {
	r := gin.Default()

	r.Static("/uploads", "./uploads")

	routes.SetupUserRouter(r)
	routes.SetupAuthRouter(r)
	routes.SetupTripRouter(r)

	httpServer := &http.Server{
		Addr:    ":8069",
		Handler: r,
	}

	if err := httpServer.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		logrus.Fatal("Failed to start InnoFT Backend:", err)
		return
	}
}
