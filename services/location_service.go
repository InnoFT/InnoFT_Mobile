package services

import (
	"FlutterBackend/initializers"
	"FlutterBackend/models"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/sirupsen/logrus"
	"net/http"
	"os"
)

func FindOrCreateLocation(latitude, longitude float64) (models.Location, error) {
	var location models.Location

	err := initializers.DB.Where("latitude = ? AND longitude = ?", latitude, longitude).First(&location).Error
	if err == nil {
		return location, nil
	}

	city, address, err := getCityAndAddressFromYandex(latitude, longitude)
	if err != nil {
		return models.Location{}, err
	}

	newLocation := models.Location{
		City:      city,
		Address:   address,
		Latitude:  latitude,
		Longitude: longitude,
	}

	if err := initializers.DB.Create(&newLocation).Error; err != nil {
		return models.Location{}, err
	}

	return newLocation, nil
}

func getCityAndAddressFromYandex(latitude, longitude float64) (string, string, error) {
	var yandexAPIKey = os.Getenv("YANDEX_API_KEY")
	var yandexAPIURL = "https://geocode-maps.yandex.ru/1.x/?apikey=" + yandexAPIKey + "&format=json&geocode="
	url := fmt.Sprintf("%s%f,%f", yandexAPIURL, longitude, latitude)

	resp, err := http.Get(url)
	if err != nil {
		return "", "", errors.New("failed to make request to Yandex Maps API")
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		logrus.Error(resp)
		return "", "", errors.New("failed to get a valid response from Yandex Maps API")
	}

	var result struct {
		Response struct {
			GeoObjectCollection struct {
				MetaDataProperty struct{} `json:"metaDataProperty"`
				FeatureMember    []struct {
					GeoObject struct {
						MetaDataProperty struct {
							GeocoderMetaData struct {
								Address struct {
									Formatted string `json:"formatted"`
								} `json:"Address"`
								AddressDetails struct {
									Country struct {
										AdministrativeArea struct {
											SubAdministrativeArea struct {
												Locality struct {
													City string `json:"LocalityName"`
												} `json:"Locality"`
											} `json:"SubAdministrativeArea"`
										} `json:"AdministrativeArea"`
									} `json:"Country"`
								} `json:"AddressDetails"`
							} `json:"GeocoderMetaData"`
						} `json:"metaDataProperty"`
					} `json:"GeoObject"`
				} `json:"featureMember"`
			} `json:"GeoObjectCollection"`
		} `json:"response"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", "", errors.New("failed to decode Yandex Maps API response")
	}

	if len(result.Response.GeoObjectCollection.FeatureMember) == 0 {
		return "", "", errors.New("no location data found for the given coordinates")
	}

	geoObject := result.Response.GeoObjectCollection.FeatureMember[0].GeoObject
	formattedAddress := geoObject.MetaDataProperty.GeocoderMetaData.Address.Formatted

	city := geoObject.MetaDataProperty.GeocoderMetaData.AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.Locality.City

	return city, formattedAddress, nil
}
