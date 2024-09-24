package routes

import (
	"FlutterBackend/controllers"
	"github.com/gin-gonic/gin"
)

func SetupAuthRouter(r *gin.Engine) {
	auth := r.Group("")
	auth.POST("/login", controllers.Login)
	auth.POST("/logout", controllers.Logout)
	auth.POST("/register", controllers.Register)
}
