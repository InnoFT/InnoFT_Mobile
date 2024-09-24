package models

import "time"

type Review struct {
	ReviewID   uint      `gorm:"primaryKey"`
	TripID     uint      `gorm:"not null"`
	ReviewerID uint      `gorm:"not null"`
	Rating     float32   `gorm:"not null"`
	Comments   string    `gorm:"type:text"`
	ReviewDate time.Time `gorm:"autoCreateTime"`
	Trip       Trip      `gorm:"foreignKey:TripID;constraint:OnDelete:CASCADE"`
	Reviewer   User      `gorm:"foreignKey:ReviewerID;constraint:OnDelete:CASCADE"`
}
