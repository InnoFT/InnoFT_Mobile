# InnoFT Mobile

Welcome to the InnoFT Mobile repository! This project is an app to find trip mates for all your trips. Below, you’ll find detailed instructions for setting up and using the application, as well as screenshots and GIFs demonstrating its features.

## Table of Contents
- [Screenshots and GIFs](#screenshots-and-gifs)
- [Setup](#setup)
- [Usage](#usage)
- [Features](#features)
- [Contributing](#contributing)
- [License](#license)

## Screenshots
Here are some screenshots showing the application in action:

| Screenshot 1  | Screenshot 2  | Screenshot 3  |
|:-------------:|:-------------:|:------:|
| ![Screenshot1](https://github.com/user-attachments/assets/ae74c945-e7b2-4ade-9436-0c4bccbe7cef) | ![Screenshot2](https://github.com/user-attachments/assets/aa0962d6-5d7b-47bc-9589-37aeae26613d) | ![Screenshot3](https://github.com/user-attachments/assets/708be051-b29b-4961-8ec0-3c16563d2d20) |


## Setup

To set up the project locally, follow these steps:

1. **Clone the repository front branch: design:**
    ```bash
    git clone https://github.com/InnoFT/InnoFT_Mobile.git
    git checkout design
    git pull
    cd InnoFT_Mobile
    ```

2. **Install dependencies:**
    ```bash
    flutter pub get
    ```

3. **Set up environment variables:**
    Add any necessary environment variables required by the app (such as API keys).

4. **Clone the repository back branch: backend:**
    ```bash
    git clone https://github.com/InnoFT/InnoFT_Mobile.git
    git checkout backend
    git pull
    cd InnoFT_Mobile
    ```
5. **Install dependencies:**
    ```bash
    go mod tidy
    ```
6. **Run the app:**
    ```bash
    go run main.go
    ```

7. **Run the app:**
    ```bash
    flutter run
    ```
Make sure you have Flutter and GO installed. If you don’t, follow the installation instructions on [Flutter's official website](https://flutter.dev/docs/get-started/install).

## Usage

**TBC**

## Features

Here is a list of features implemented in the app:
- **Authentication:** Secure user login and registration.
- **Map Integration:** Display and interact with locations using [Mapbox/Yandex].
- **Trip Creation:** Set pickup and destination points with an intuitive UI.
- **Profile Management:** View and edit user profile details.

## Contributing

If you’d like to contribute to this project, feel free to open a pull request or submit an issue. For major changes, please discuss them in an issue first to ensure they align with the project’s direction.

## License

This project is licensed under the [MIT License](LICENSE).
