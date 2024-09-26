package controllers

import (
	"FlutterBackend/initializers"
	"FlutterBackend/models"
	"FlutterBackend/services"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func AttachVehicle(c *gin.Context) {
	driverID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found in context"})
		return
	}

	var existingVehicle models.Vehicle
	if err := initializers.DB.Where("driver_id = ?", driverID).First(&existingVehicle).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Driver already has an attached vehicle"})
		return
	}

	licensePlate := c.PostForm("license_plate")
	brand := c.PostForm("brand")
	model := c.PostForm("model")
	seatsAvailable := c.PostForm("seats_available")

	if licensePlate == "" || brand == "" || model == "" || seatsAvailable == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "All fields are required"})
		return
	}

	vehicle := models.Vehicle{
		DriverID:       driverID.(uint),
		LicensePlate:   licensePlate,
		Brand:          brand,
		Model:          model,
		SeatsAvailable: parseSeatsAvailable(seatsAvailable),
		CarPic:         "",
	}

	/*carPhotoPath, err := services.SaveCarPhoto(c, vehicle, carPhoto)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save car photo"})
		return
	}

	vehicle.CarPic = carPhotoPath
	*/

	if err := initializers.DB.Create(&vehicle).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to attach vehicle"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Vehicle attached successfully", "vehicle": vehicle})
}

func EditVehicle(c *gin.Context) {
	driverID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found in context"})
		return
	}

	var vehicle models.Vehicle
	if err := initializers.DB.Where("driver_id = ?", driverID).First(&vehicle).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No attached vehicle found for this driver"})
		return
	}

	licensePlate := c.PostForm("license_plate")
	brand := c.PostForm("brand")
	model := c.PostForm("model")
	seatsAvailable := c.PostForm("seats_available")

	if licensePlate != "" {
		vehicle.LicensePlate = licensePlate
	}
	if brand != "" {
		vehicle.Brand = brand
	}
	if model != "" {
		vehicle.Model = model
	}
	if seatsAvailable != "" {
		vehicle.SeatsAvailable = parseSeatsAvailable(seatsAvailable)
	}

	carPhoto, err := c.FormFile("car_photo")
	if err == nil {
		carPhotoPath, err := services.SaveCarPhoto(c, vehicle, carPhoto)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update car photo"})
			return
		}
		vehicle.CarPic = carPhotoPath
	}

	if err := initializers.DB.Save(&vehicle).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update vehicle"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Vehicle updated successfully", "vehicle": vehicle})
}

func parseSeatsAvailable(seatsAvailable string) int {
	seats, err := strconv.Atoi(seatsAvailable)
	if err != nil {
		return 1
	}
	return seats
}
