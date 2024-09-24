package models

type BookingStatus string

const (
	Confirmed BookingStatus = "Confirmed"
	Cancelled BookingStatus = "Cancelled"
)

type PaymentStatus string

const (
	Pending  PaymentStatus = "Pending"
	Accepted PaymentStatus = "Accepted"
)

type Booking struct {
	BookingID     uint          `gorm:"primaryKey"`
	TripID        uint          `gorm:"not null"`
	PassengerID   uint          `gorm:"not null"`
	SeatsBooked   int           `gorm:"not null"`
	BookingStatus BookingStatus `gorm:"not null;default:'Confirmed'"`
	TotalPrice    float64       `gorm:"not null"`
	PaymentStatus PaymentStatus `gorm:"not null;default:'Pending'"`
	Trip          Trip          `gorm:"foreignKey:TripID;constraint:OnDelete:CASCADE"`
	Passenger     User          `gorm:"foreignKey:PassengerID;constraint:OnDelete:CASCADE"`
}
