package initializers

import (
	"FlutterBackend/models"
	"fmt"
	"github.com/sirupsen/logrus"
)

func SyncDatabase() {
	migrateModel(models.Location{})
	migrateModel(models.User{})
	migrateModel(models.Vehicle{})
	migrateModel(models.Trip{})
	migrateModel(models.Booking{})
	migrateModel(models.Review{})
}

func migrateModel(model interface{}) {
	if !DB.Migrator().HasTable(model) {
		if err := DB.AutoMigrate(model); err != nil {
			panic(fmt.Sprintf("Database migration for %T failed: %v", model, err))
		}
	} else {
		logrus.Infof("Skipping migration for %T - table already exists", model)
	}
}
