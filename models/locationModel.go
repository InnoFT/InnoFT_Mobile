package models

type Location struct {
	LocationID uint    `gorm:"primaryKey"`
	City       string  `gorm:"not null"`
	Address    string  `gorm:"not null"`
	Latitude   float64 `gorm:"not null"`
	Longitude  float64 `gorm:"not null"`
}
