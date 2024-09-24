package middleware

import (
	"FlutterBackend/utils"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
	"net/http"
)

var blocklist = make(map[string]bool)

func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		tokenString, err := c.Cookie("Authorization")

		if err != nil {
			logrus.WithError(err).Warn("Failed to retrieve Authorization cookie")
			c.AbortWithStatus(http.StatusUnauthorized)
			return
		}

		if blocklist[tokenString] {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "Invalid or expired token",
			})
			c.Abort()
			return
		}

		claims, err := utils.ValidateToken(tokenString)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Token is invalid."})
			c.Abort()
			return
		}

		c.Set("userID", claims.UserID)

		c.Next()
	}
}

func BlocklistToken(token string) {
	blocklist[token] = true
}
