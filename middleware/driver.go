package middleware

import (
	"FlutterBackend/initializers"
	"FlutterBackend/models"
	"github.com/gin-gonic/gin"
	"net/http"
)

func DriverMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		userId, exists := c.Get("userID")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized. Context value not found"})
			c.Abort()
			return
		}

		var user models.User

		if err := initializers.DB.First(&user, userId).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to validate user"})
			c.Abort()
			return
		}

		if user.Role != models.Driver {
			c.JSON(http.StatusForbidden, gin.H{"error": "Only drivers are allowed to access this route"})
			c.Abort()
			return
		}

		c.Next()
	}
}
