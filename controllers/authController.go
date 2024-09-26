package controllers

import (
	"FlutterBackend/initializers"
	"FlutterBackend/middleware"
	"FlutterBackend/models"
	"FlutterBackend/utils"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

func Register(c *gin.Context) {
	var input struct {
		Name     string `json:"name" binding:"required"`
		Email    string `json:"email" binding:"required,email"`
		Phone    string `json:"phone" binding:"required"`
		Password string `json:"password" binding:"required"`
		Role     string `json:"role" binding:"required,oneof='Fellow Traveller' 'Driver'"`
	}

	_, exists := c.Get("userID")
	if exists {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Already logged in"})
		return
	}

	tokenCheck, err := c.Cookie("Authorization")

	if err == nil {
		_, err := utils.ValidateToken(tokenCheck)
		if err == nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Already logged in"})
			return
		}
	}

	tokenCheck = c.GetHeader("Authorization")

	if tokenCheck != "" {
		_, err := utils.ValidateToken(tokenCheck)
		if err == nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Already logged in"})
			return
		}
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var existingUser models.User
	if err := initializers.DB.Where("email = ?", input.Email).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email already registered"})
		return
	}

	passwordHash, err := utils.HashPassword(input.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	user := models.User{
		Name:         input.Name,
		Email:        input.Email,
		Phone:        input.Phone,
		PasswordHash: passwordHash,
		Role:         models.Role(input.Role),
	}

	if err := initializers.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Registration successful"})
}

func Login(c *gin.Context) {
	var input struct {
		Email    string `json:"email" binding:"required,email"`
		Password string `json:"password" binding:"required"`
	}

	_, exists := c.Get("userID")
	if exists {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Already logged in"})
		return
	}

	tokenCheck, err := c.Cookie("Authorization")

	if err == nil {
		_, err := utils.ValidateToken(tokenCheck)
		if err == nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Already logged in"})
			return
		}
	}

	tokenCheck = c.GetHeader("Authorization")

	if tokenCheck != "" {
		_, err := utils.ValidateToken(tokenCheck)
		if err == nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Already logged in"})
			return
		}
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	if err := initializers.DB.Where("email = ?", input.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	if !utils.CheckPasswordHash(input.Password, user.PasswordHash) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	token, err := utils.GenerateJWT(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.Set("userID", user.UserID)

	c.SetSameSite(http.SameSiteNoneMode)
	c.SetCookie("Authorization", token, 3600, "/", "", false, true)

	logrus.WithFields(logrus.Fields{
		"user_id": user.UserID,
	}).Info("User logged in successfully")

	c.JSON(http.StatusOK, gin.H{"user": user.Name, "token": token})
}

func Logout(c *gin.Context) {
	tokenString, err := c.Cookie("Authorization")
	if err != nil {
		tokenString = c.GetHeader("Authorization")
		if tokenString == "" {
			logrus.WithError(err).Warn("Failed to retrieve Authorization cookie")
			c.AbortWithStatus(http.StatusUnauthorized)
			return
		}
	}

	middleware.BlocklistToken(tokenString)

	c.SetSameSite(http.SameSiteNoneMode)
	c.SetCookie("Authorization", "", -1, "/", "", false, true)

	c.JSON(http.StatusOK, gin.H{
		"message": "Logged out",
	})
}
