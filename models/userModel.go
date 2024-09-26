package models

import (
	"time"
)

type Role string

const (
	FellowTraveller Role = "Fellow Traveller"
	Driver          Role = "Driver"
)

type User struct {
	UserID        uint    `gorm:"primaryKey"`
	Name          string  `gorm:"not null"`
	Email         string  `gorm:"unique;not null"`
	Phone         string  `gorm:"unique;not null"`
	PasswordHash  string  `gorm:"not null"`
	Role          Role    `gorm:"tnot null"`
	Rating        float32 `gorm:"default:0.0"`
	ProfilePic    string  `gorm:"type:text"`
	City          string
	ProfilePicURL string
	CreatedAt     time.Time `gorm:"autoCreateTime"`
	UpdatedAt     time.Time `gorm:"autoUpdateTime"`
}
