📝 Full-Stack Task Manager Application

A robust, full-stack task management solution featuring a secure Node.js backend and a modern, responsive Flutter mobile application. This project demonstrates clean architecture, secure authentication flows (JWT), and real-time state management.

![App Screenshots Placeholder](Add your images here)

🚀 Tech Stack

Backend API

Runtime: Node.js & Express

Language: TypeScript

Database: SQLite (Dev) / PostgreSQL (Production ready)

ORM: Prisma

Security: JWT (Access + Refresh Tokens), Bcrypt (Password Hashing)

Validation: Zod

Mobile App

Framework: Flutter (Android & iOS)

State Management: Riverpod 2.0 (ConsumerWidget, autoDispose)

Routing: GoRouter

Networking: Dio (with Interceptors)

Storage: Flutter Secure Storage

UI/UX: Flutter Animate, Google Fonts, Custom Theming (Light/Dark support)

🛠️ Backend API (Node.js)

Key Features

Secure Authentication: Full Login/Register flows with hashed passwords.

Token Management: Implements short-lived Access Tokens (15m) and long-lived Refresh Tokens (7d) with automatic rotation.

Task Management: Complete CRUD operations (Create, Read, Update, Delete).

Advanced Querying: Supports pagination, status filtering, and search by title.

Middleware: Protected routes using custom JWT middleware.

Setup & Installation

Navigate to the backend folder:

cd task_manager_backend


Install Dependencies:

npm install


Environment Configuration:
Create a .env file in the root directory and add the following:

# Database Connection (SQLite for local dev)
DATABASE_URL="file:./dev.db"

# Security Keys (Replace with random strings for production)
JWT_ACCESS_SECRET="your_super_secret_access_key"
JWT_REFRESH_SECRET="your_super_secret_refresh_key"

# Port
PORT=3000


Generate Prisma Client:
This creates the TypeScript types based on your schema.

npx prisma generate


Database Migration:
Initialize the SQLite database and create tables.

npx prisma migrate dev --name init


Run the Server:

npm run dev


The server will start at http://localhost:3000

📱 Mobile App (Flutter)

Key Features

Modern UI: Beautiful gradient backgrounds, animated cards, and custom headers.

Auto-Refresh Logic: Smart network interceptors automatically refresh expired tokens transparently without logging the user out.

Optimistic UI: Tasks appear/update/delete instantly on the screen before the server responds for a snappy feel.

Robust Error Handling: Friendly error screens with "Pull to Retry" functionality.

Secure Storage: Tokens are stored in the device's secure keychain/keystore.

Setup & Installation

Navigate to the app folder:

cd task_manager_app


Install Dependencies:

flutter pub get


Configure Network (Important):
Open lib/core/services/api_service.dart and check the _baseUrl.

For Android Emulator: Use http://10.0.2.2:3000

For iOS Simulator: Use http://localhost:3000

For Real Device: Use your computer's local IP (e.g., http://192.168.1.5:3000)

Run the App:

flutter run


📡 API Endpoints Reference

Method

Endpoint

Description

Auth Required

POST

/auth/register

Register a new user

❌

POST

/auth/login

Login and receive tokens

❌

POST

/auth/refresh

Refresh expired access token

❌

GET

/tasks

Get all tasks (supports ?page=1&limit=10)

✅

POST

/tasks

Create a new task

✅

PATCH

/tasks/:id

Update task status or details

✅

DELETE

/tasks/:id

Delete a task

✅
