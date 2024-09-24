package controllers

import (
	"FlutterBackend/initializers"
	"FlutterBackend/models"
	"FlutterBackend/services"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetUserProfile(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found in context"})
		return
	}

	var user models.User
	if err := initializers.DB.First(&user, userID.(uint)).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user"})
		return
	}

	user.PasswordHash = ""

	if user.ProfilePic != "" {
		// Assuming the server is running on localhost:8080, change as per deployment URL
		user.ProfilePicURL = fmt.Sprintf("%s/user/profile/picture", c.Request.Host)
	}

	c.JSON(http.StatusOK, gin.H{"user": user})
}

func UpdateUserProfile(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found in context"})
		return
	}

	var user models.User
	if err := initializers.DB.First(&user, userID.(uint)).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user"})
		return
	}

	if err := c.Request.ParseMultipartForm(10 << 20); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to parse form data"})
		return
	}

	name := c.PostForm("name")
	city := c.PostForm("city")

	if name == "" || city == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Name and City are required"})
		return
	}

	user.Name = name
	user.City = city

	file, err := c.FormFile("profile_pic")
	if err == nil {
		profilePicPath, err := services.SaveProfilePicture(c, user, file)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save profile picture"})
			return
		}
		user.ProfilePic = profilePicPath
	}

	if err := initializers.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user profile"})
		return
	}

	user.PasswordHash = ""

	c.JSON(http.StatusOK, gin.H{
		"message": "Profile updated successfully",
		"user":    user,
	})
}

func GetProfilePicture(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found in context"})
		return
	}

	var user models.User
	if err := initializers.DB.First(&user, userID.(uint)).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user"})
		return
	}

	if err := services.ServeProfilePicture(c, user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to serve profile picture"})
		return
	}
}
