# Chatify

Chatify is a feature-rich, real-time chat application built with Flutter and Firebase. It provides seamless one-on-one and group messaging, a clean user interface, and a robust backend powered by Google's Firebase.

## Features

*   **Real-time Messaging:** Instant messaging with real-time updates for one-on-one and group conversations.
*   **User Authentication:** Secure email and password authentication using Firebase Auth.
*   **Group Chats:** Create and manage group conversations with multiple participants.
*   **Clean UI:** A modern and intuitive user interface with light and dark modes.
*   **Cross-Platform:** Built with Flutter, Chatify runs on both Android and iOS from a single codebase.

## Architecture

The application follows a clean and scalable architecture, separating concerns into three main layers:

*   **UI Layer (`lib/pages`, `lib/components`):** The user interface is built with Flutter widgets. The `pages` directory contains the main screens of the application, while the `components` directory contains reusable UI elements.
*   **Service Layer (`lib/services`):** This layer encapsulates the business logic of the application. It includes services for authentication (`AuthService`), one-on-one chat (`ChatServices`), and group chat (`GroupService`).
*   **Data Layer (`lib/models`):** The data models define the structure of the data used in the application, such as users, messages, and groups.

The backend is powered by Firebase, utilizing:

*   **Firebase Authentication:** For user management and authentication.
*   **Cloud Firestore:** As the real-time database for storing messages, user information, and group data.
*   **Firebase Storage:** For storing media files (e.g., images, videos).

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

*   Flutter SDK: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
*   Firebase Account: [https://firebase.google.com/](https://firebase.google.com/)

### Installation

1.  **Clone the repo**
    ```sh
    git clone https://github.com/your_username_/Chatify.git
    ```
2.  **Navigate to the project directory**
    ```sh
    cd Chatify
    ```
3.  **Install dependencies**
    ```sh
    flutter pub get
    ```
4.  **Set up Firebase**
    *   Create a new Firebase project.
    *   Add an Android and/or iOS app to your Firebase project.
    *   Follow the Firebase setup instructions and add the `google-services.json` file to the `android/app` directory and the `GoogleService-Info.plist` file to the `ios/Runner` directory.
5.  **Run the app**
    ```sh
    flutter run
    ```

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

Don't forget to give the project a star! Thanks again!

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request