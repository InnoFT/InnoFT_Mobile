package models

import (
	"time"
)

type Trip struct {
	TripID          uint      `gorm:"primaryKey"`
	DriverID        uint      `gorm:"not null"`
	StartLocationID uint      `gorm:"not null"`
	EndLocationID   uint      `gorm:"not null"`
	DepartureTime   time.Time `gorm:"not null"`
	TotalSeats      int       `gorm:"not null"`
	AvailableSeats  int       `gorm:"not null"`
	PricePerSeat    float64   `gorm:"not null"`
	Driver          User      `gorm:"foreignKey:DriverID;constraint:OnDelete:SET NULL"`
	StartLocation   Location  `gorm:"foreignKey:StartLocationID;constraint:OnDelete:RESTRICT"`
	EndLocation     Location  `gorm:"foreignKey:EndLocationID;constraint:OnDelete:RESTRICT"`
}
