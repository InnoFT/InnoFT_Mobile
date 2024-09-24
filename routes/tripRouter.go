package routes

import (
	"FlutterBackend/controllers"
	"FlutterBackend/middleware"
	"github.com/gin-gonic/gin"
)

func SetupTripRouter(r *gin.Engine) {
	trips := r.Group("/trips")
	trips.Use(middleware.AuthMiddleware()).Use(middleware.DriverMiddleware())
	{
		trips.POST("/create", controllers.CreateTrip)
		trips.GET("/my", controllers.GetPlannedTripsForDriver)
		trips.GET("/available", controllers.SearchTrips)
	}
}
