# PawPal App

## Setup Steps
1. Install dependecies by running the following command:
```bash
flutter pub get
```
2. Install XAMPP
3. Import pawpal_db.sql to XAMPP
4. Copy API folder (./server/backend) to htdocs folder
5. Copy uploads folder to the /backend folder
6. Change IPv4 address at myconfig.dart
7. Run the app by running the following command in the vscode terminal:
```bash
flutter run
```

## API Explanation
### 1. config.php
Handles database connection

### 2. login_user.php
Handles user login and authentication 

### 3. register_user.php    
Handles user registration and ecryption of password and check email already registered or not.

### 4. get_my_pets.php
Loads everything about submitted pets

### 5. submit_pet.php
Handles submissions of the pets and images of the pets

## Sample JSON Response
### Example of JSON Response for get_my_pets.php
#### 1. Success Response 
```json
{
  "status": "success",
  "message": "Pet added successfully"
}
```    
#### 2. Failed - no images provided
```json
{
  "status": "failed",
  "message": "No images provided"
}
```
### Example of JSON Response for submit_pet.php
#### 1. Failed - required POST field is missing
```json
{
  "status": "failed",
  "message": "No data received"
}
```
#### 2. Success response
```json
{
  "status": "success",
  "data": null
}
```
