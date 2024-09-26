package services

import (
	"FlutterBackend/initializers"
	"FlutterBackend/models"
	"FlutterBackend/utils"
	"fmt"
	"mime/multipart"
	"os"
	"path/filepath"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sirupsen/logrus"
)

func SaveProfilePicture(c *gin.Context, user models.User, file *multipart.FileHeader) (string, error) {
	fileUUID := uuid.New().String()
	fileExtension := filepath.Ext(file.Filename)

	userHash := utils.HashUserID(user.UserID)
	saveDir := fmt.Sprintf("uploads/profile_pics/%s", userHash)
	savePath := fmt.Sprintf("%s/%s%s", saveDir, fileUUID, fileExtension)

	if err := os.MkdirAll(saveDir, 0755); err != nil {
		logrus.WithFields(logrus.Fields{
			"directory": saveDir,
			"error":     err,
		}).Error("Unable to create directory")
		return "", err
	}

	if err := c.SaveUploadedFile(file, savePath); err != nil {
		logrus.WithFields(logrus.Fields{
			"file":  file.Filename,
			"path":  savePath,
			"error": err,
		}).Error("Unable to save file")
		return "", err
	}

	logrus.WithFields(logrus.Fields{
		"username": user.Name,
		"filePath": savePath,
	}).Info("Profile picture saved successfully")

	user.ProfilePicURL = savePath
	if err := initializers.DB.Save(&user).Error; err != nil {
		logrus.WithFields(logrus.Fields{
			"username": user.Name,
			"error":    err,
		}).Error("Failed to update user profile picture")
		return "", err
	}

	return savePath, nil
}

func ServeProfilePicture(c *gin.Context, user models.User) error {
	if _, err := os.Stat(user.ProfilePic); os.IsNotExist(err) {
		logrus.WithFields(logrus.Fields{
			"username": user.Name,
			"filePath": user.ProfilePic,
		}).Error("Profile picture not found")
		return err
	}

	logrus.WithFields(logrus.Fields{
		"username": user.Name,
		"filePath": user.ProfilePic,
	}).Info("Serving profile picture")

	c.File(user.ProfilePic)
	return nil
}

func SaveCarPhoto(c *gin.Context, vehicle models.Vehicle, file *multipart.FileHeader) (string, error) {
	fileUUID := uuid.New().String()
	fileExtension := filepath.Ext(file.Filename)

	vehicleHash := utils.HashUserID(vehicle.VehicleID)
	saveDir := fmt.Sprintf("uploads/vehicles/%d", vehicleHash)
	savePath := fmt.Sprintf("%s/%s%s", saveDir, fileUUID, fileExtension)

	if err := os.MkdirAll(saveDir, 0755); err != nil {
		logrus.WithFields(logrus.Fields{
			"directory": saveDir,
			"error":     err,
		}).Error("Unable to create directory")
		return "", err
	}

	if err := c.SaveUploadedFile(file, savePath); err != nil {
		logrus.WithFields(logrus.Fields{
			"file":  file.Filename,
			"path":  savePath,
			"error": err,
		}).Error("Unable to save file")
		return "", err
	}

	logrus.WithFields(logrus.Fields{
		"vehicle_id": vehicle.VehicleID,
		"filePath":   savePath,
	}).Info("Car photo saved successfully")

	vehicle.CarPicURL = savePath
	if err := initializers.DB.Save(&vehicle).Error; err != nil {
		logrus.WithFields(logrus.Fields{
			"vehicle_id": vehicle.VehicleID,
			"error":      err,
		}).Error("Failed to update vehicle picture")
		return "", err
	}

	return savePath, nil
}

func ServeCarPhoto(c *gin.Context, vehicle models.Vehicle) error {
	if _, err := os.Stat(vehicle.CarPic); os.IsNotExist(err) {
		logrus.WithFields(logrus.Fields{
			"username": vehicle.Model,
			"filePath": vehicle.CarPic,
		}).Error("Vehicle photo not found")
		return err
	}

	logrus.WithFields(logrus.Fields{
		"username": vehicle.Model,
		"filePath": vehicle.CarPic,
	}).Info("Serving vehicle picture")

	c.File(vehicle.CarPic)
	return nil
}
