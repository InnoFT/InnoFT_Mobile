package models

type Vehicle struct {
	VehicleID      uint   `gorm:"primaryKey"`
	DriverID       uint   `gorm:"not null"`
	LicensePlate   string `gorm:"unique;not null"`
	Brand          string `gorm:"not null"`
	Model          string `gorm:"not null"`
	SeatsAvailable int    `gorm:"not null"`
	CarPic         string `gorm:"type:text"`
	CarPicURL      string
	Driver         User `gorm:"foreignKey:DriverID;constraint:OnDelete:CASCADE"`
}
