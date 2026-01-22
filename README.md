# VemoraStore

<img width="4141" height="2804" alt="VemoraStore Mockup" src="https://github.com/user-attachments/assets/c0ee3aeb-dc47-487a-84be-2b81672f86b1" />

## Overview

VemoraStore is an iOS demo project that demonstrates the architecture, navigation, and user interface of a modern e-commerce mobile application focused on furniture and home goods.

The project was developed as part of an educational work and showcases practical approaches to building scalable iOS applications using clean architecture principles, predictable state management, and modular navigation.

## Project Goals

- Demonstrate a real-world iOS application structure
- Apply MVVM + Coordinator architecture
- Showcase interaction with remote and local data sources
- Implement user authorization, catalog browsing, and order flow
- Emphasize clean code, separation of responsibilities, and scalability

## Key Features

- User registration and authorization
- Product catalog with categories and brands
- Favorites and cart management
- Order placement and order history
- User profile management
- Map-based address selection
- Offline-ready data layer using local persistence

## Architecture

The application is built using the **MVVM** pattern combined with the **Coordinator** pattern for navigation.

Key architectural decisions:
- ViewControllers are responsible only for UI
- Business logic is encapsulated in ViewModels
- Navigation logic is handled by Coordinators
- Data access is abstracted via repositories and services
- Dependency Injection is centralized using FactoryKit

This approach ensures:
- Low coupling between modules
- Clear separation of concerns
- Improved testability and maintainability

## Tech Stack

- **Swift**
- **UIKit**
- **MVVM**
- **Coordinator**
- **Combine**
- **async / await**
- **Dependency Injection (FactoryKit)**
- **Firebase Authentication**
- **Firebase Firestore**
- **Core Data**
- **UserDefaults**
- **Keychain**
- **MapKit**
- **Core Location**
- **FileManager**

## Data Storage

- **Firebase Firestore** is used as the primary remote data source for users, products, and orders.
- **Core Data** is used for local caching and offline access.
- **Yandex Cloud Storage** is used to store images of products, categories, and brands.  
  Image URLs are stored in Firestore documents and loaded dynamically in the app.

## Project Scope

The project includes **27 screens**, covering the full user journey:
- Authorization and registration
- Catalog browsing
- Favorites and cart
- Checkout and order confirmation
- Profile and order history

This makes the project close to a real production-level application in terms of structure and complexity.

## Notes

This project is intended for **educational and demonstration purposes**.  
It focuses on architecture, code quality, and application structure rather than production deployment.

## License

This project is provided for educational use only.
