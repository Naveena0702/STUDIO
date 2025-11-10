# ChronoCare Backend API

Backend REST API for the ChronoCare health management application.

## Features

- User authentication (JWT-based)
- Journal entries management
- Diet/meal tracking
- Water intake tracking
- Symptom analysis storage
- SQLite database for data persistence

## Prerequisites

- Node.js (v14 or higher)
- npm or yarn

## Installation

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file with your configuration:
```
PORT=3000
NODE_ENV=production
JWT_SECRET=your-secret-key-change-this-in-production
# Optional CORS (comma-separated origins): ALLOWED_ORIGINS=https://yourapp.com,https://admin.yourapp.com
# Optional S3 config (uncomment if using cloud storage for medical records)
# S3_BUCKET=your-bucket-name
# AWS_REGION=us-east-1
# AWS_ACCESS_KEY_ID=YOUR_KEY
# AWS_SECRET_ACCESS_KEY=YOUR_SECRET
```

3. Initialize the database:
```bash
npm run init-db
```

## Running the Server

### Development mode (with auto-reload):
```bash
npm run dev
```

### Production mode:
```bash
npm start
```

The server will start on `http://localhost:3000` (or the port specified in `.env`).

## API Endpoints

### Health Check
- `GET /api/health` - Check if the API is running

### Authentication
- `POST /api/auth/register` - Register a new user
  ```json
  {
    "email": "user@example.com",
    "password": "password123",
    "name": "John Doe"
  }
  ```
- `POST /api/auth/login` - Login user
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```
- `GET /api/auth/verify` - Verify JWT token (requires Authorization header)

### Journal Entries
All endpoints require authentication (Bearer token in Authorization header).

- `GET /api/journal` - Get all journal entries
- `GET /api/journal/:id` - Get a specific journal entry
- `POST /api/journal` - Create a new journal entry
  ```json
  {
    "content": "Feeling great today!",
    "mood": 5,
    "energy": 4
  }
  ```
- `PUT /api/journal/:id` - Update a journal entry
- `DELETE /api/journal/:id` - Delete a journal entry
- `GET /api/journal/analytics/summary` - Get journal analytics

### Diet/Meals
All endpoints require authentication.

- `GET /api/diet` - Get all meal entries
- `GET /api/diet/date/:date` - Get meals for a specific date (YYYY-MM-DD)
- `GET /api/diet/:id` - Get a specific meal entry
- `POST /api/diet` - Create a new meal entry
  ```json
  {
    "food": "Chicken Salad",
    "calories": 350,
    "mealType": "Lunch"
  }
  ```
- `PUT /api/diet/:id` - Update a meal entry
- `DELETE /api/diet/:id` - Delete a meal entry
- `GET /api/diet/analytics/summary` - Get nutrition summary
- `GET /api/diet/analytics/today` - Get today's nutrition summary

### Water Intake
All endpoints require authentication.

- `GET /api/water` - Get all water entries
- `GET /api/water/date/:date` - Get water entries for a specific date
- `GET /api/water/:id` - Get a specific water entry
- `POST /api/water` - Create a new water entry
  ```json
  {
    "glasses": 1
  }
  ```
- `DELETE /api/water/:id` - Delete a water entry
- `GET /api/water/analytics/today` - Get today's water summary
- `GET /api/water/analytics/summary` - Get water analytics

### Symptom Analysis
All endpoints require authentication.

- `GET /api/symptoms` - Get all symptom analyses
- `GET /api/symptoms/:id` - Get a specific symptom analysis
- `POST /api/symptoms` - Create a new symptom analysis
  ```json
  {
    "selectedSymptoms": "Headache, Fever",
    "customDescription": "I've been experiencing these symptoms for 2 days"
  }
  ```
- `DELETE /api/symptoms/:id` - Delete a symptom analysis

## Authentication

All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <your-token>
```

Tokens are valid for 7 days. You can get a token by registering or logging in through `/api/auth/register` or `/api/auth/login`.

## Database

The backend uses SQLite for data persistence. The database file (`chronocare.db`) is created automatically when you run `npm run init-db`.

### Database Schema

- **users** - User accounts with email, password (hashed), and name
- **journal_entries** - Journal entries with content, mood, energy, and timestamps
- **meal_entries** - Meal entries with food, calories, meal type, and timestamps
- **water_entries** - Water intake entries with number of glasses and timestamps
- **symptom_analyses** - Symptom analysis records with symptoms and analysis results

## Example Usage

### Register a new user:
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'
```

### Create a journal entry:
```bash
curl -X POST http://localhost:3000/api/journal \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your-token>" \
  -d '{
    "content": "Had a great workout today!",
    "mood": 5,
    "energy": 4
  }'
```

## Development

The backend uses:
- **Express.js** - Web framework
- **SQLite3** - Database
- **bcrypt** - Password hashing
- **jsonwebtoken** - JWT authentication
- **cors** - Cross-origin resource sharing
- **dotenv** - Environment variable management

## Security Notes

- Passwords are hashed using bcrypt before storage
- JWT tokens are used for authentication
- CORS is restricted via `ALLOWED_ORIGINS` in production
- Basic rate limiting is enabled for `/api`
- Request logging via `morgan`
- Database uses foreign key constraints and cascading deletes

## Future Enhancements

- Integration with AI services for symptom analysis
- Email verification
- Password reset email sender
- Migration to PostgreSQL for production use
- API documentation with Swagger/OpenAPI
