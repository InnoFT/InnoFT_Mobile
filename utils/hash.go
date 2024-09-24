package utils

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
)

func HashUserID(userID uint) string {
	hash := sha256.New()
	hash.Write([]byte(fmt.Sprintf("%d", userID)))
	return hex.EncodeToString(hash.Sum(nil))[:20]
}
