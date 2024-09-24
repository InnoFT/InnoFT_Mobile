package routes

import (
	"FlutterBackend/controllers"
	"FlutterBackend/middleware"
	"github.com/gin-gonic/gin"
)

func SetupUserRouter(r *gin.Engine) {
	router := r.Group("/user")
	router.Use(middleware.AuthMiddleware())
	{
		router.GET("/profile", controllers.GetUserProfile)
		router.PATCH("/profile", controllers.UpdateUserProfile)
		router.GET("/profile/picture", controllers.GetProfilePicture)
	}
}
