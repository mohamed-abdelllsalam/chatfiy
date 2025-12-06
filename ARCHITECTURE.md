# Chatify Architecture

This document provides a high-level overview of the architecture of the Chatify application.

## Overview

Chatify is a real-time chat application built with Flutter and Firebase. The application is designed with a clean and scalable architecture, separating concerns into three main layers:

*   **UI Layer:** Responsible for presenting the user interface and handling user input.
*   **Service Layer:** Encapsulates the business logic of the application.
*   **Data Layer:** Defines the data models and handles data persistence.

The backend is powered by Firebase, which provides services for authentication, real-time database, and file storage.

## Architectural Diagram

```
+---------------------+      +-----------------------+      +---------------------+
|     UI Layer        |      |     Service Layer     |      |    Firebase Backend   |
| (Flutter Widgets)   |      |   (Business Logic)    |      |      (Cloud)        |
+---------------------+      +-----------------------+      +---------------------+
| - Pages             |      | - AuthService         |      | - Firebase Auth     |
| - Components        |      | - ChatServices        |      | - Cloud Firestore   |
| - Themes            |      | - GroupService        |      | - Firebase Storage  |
+---------------------+      +-----------------------+      +---------------------+
        |                              |                              |
        +------------------------------+------------------------------+
                                       |
                               +-----------------+
                               |   Data Layer    |
                               |  (Data Models)  |
                               +-----------------+
                               | - AppUser       |
                               | - Message       |
                               | - Group         |
                               | - GroupMessage  |
                               +-----------------+
```

## Layers

### UI Layer

The UI layer is responsible for everything related to the user interface. It is built with Flutter widgets and is organized into the following directories:

*   `lib/pages`: Contains the main screens of the application, such as the login page, home page, and chat page.
*   `lib/components`: Contains reusable UI elements, such as buttons, text fields, and chat bubbles.
*   `lib/themes`: Defines the visual style of the application, including the light and dark modes.

### Service Layer

The service layer contains the core business logic of the application. It acts as a bridge between the UI layer and the Firebase backend. The services are organized into the following directories:

*   `lib/services/auth`: Handles user authentication, including sign-in, sign-up, and sign-out.
*   `lib/services/chat`: Manages one-on-one chat functionality, including sending and receiving messages.
*   `lib/services/group`: Manages group chat functionality, including creating groups and sending group messages.

### Data Layer

The data layer defines the data models used in the application. These models represent the structure of the data stored in Firestore. The data models are located in the `lib/models` directory and include:

*   `AppUser`: Represents a user of the application.
*   `Message`: Represents a single message in a one-on-one chat.
*   `Group`: Represents a chat group.
*   `GroupMessage`: Represents a single message in a group chat.

## Backend

The backend of the application is powered by Firebase, which provides the following services:

*   **Firebase Authentication:** Used for user management and authentication. It supports email and password authentication.
*   **Cloud Firestore:** A NoSQL, real-time database used to store all the application data, including user information, messages, and groups.
*   **Firebase Storage:** Used to store media files, such as images and videos, that are shared in the chat.

## Data Flow

1.  The user interacts with the UI layer (e.g., sends a message).
2.  The UI layer calls a method in the corresponding service in the service layer.
3.  The service layer processes the request, interacts with the Firebase backend, and updates the data in Firestore.
4.  The UI layer listens to real-time updates from Firestore and automatically updates the UI to reflect the changes.
