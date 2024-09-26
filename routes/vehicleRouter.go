package routes

import (
	"FlutterBackend/controllers"
	"FlutterBackend/middleware"

	"github.com/gin-gonic/gin"
)

func SetupVehicleRouter(r *gin.Engine) {
	trips := r.Group("/vehicle")
	trips.Use(middleware.AuthMiddleware())
	{
		trips.POST("/attach", controllers.AttachVehicle)
	}
}
