# JIRIS — Furniture E-Commerce Application

Aplikasi e-commerce furniture yang membantu pengguna menemukan, menjelajahi, dan membeli berbagai produk furniture untuk kebutuhan hunian.

## About JIRIS

**JIRIS** is a furniture e-commerce application designed to simplify the process of discovering and purchasing furniture through a digital platform.

The application connects customers with furniture companies and provides a centralized catalog where users can explore available products.

JIRIS is developed as a digital solution to make furniture shopping more accessible, practical, and efficient.

## Key Features

### Current Development

- **User Authentication** — User registration and login.
- **Product Catalog** — Browse available furniture products.
- **Product Management** — Manage product information and images.
- **Category Management** — Organize products by category.
- **Company Management** — Manage furniture company information.
- **Shopping Cart** — Manage products selected for purchase.
- **Order Management** — Manage customer orders.
- **Image Upload** — Upload and manage product and category images.

### Planned Features

- **Visual Furniture Search** — Find similar furniture using a camera or uploaded image.
- **Style-Based Filtering** — Discover furniture based on interior design styles such as minimalist, vintage, and monochrome.
- **Furniture Discovery** — Explore products from different furniture companies.

## Technology Stack

| Component                     | Technology   |
| ----------------------------- | ------------ |
| Mobile Application            | Flutter      |
| Programming Language (Mobile) | Dart         |
| Backend                       | Node.js      |
| Backend Framework             | Express.js   |
| Database                      | PostgreSQL   |
| Database Hosting              | Aiven        |
| Image Storage                 | Cloudinary   |
| API Testing                   | Postman      |
| Version Control               | Git & GitHub |

## Project Structure

```text
JIRIS-JN/
│
├── backend/
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   ├── routes/
│   └── ...
│
├── mobile/
│   ├── android/
│   ├── ios/
│   ├── lib/
│   ├── linux/
│   ├── macos/
│   ├── windows/
│   └── ...
│
└── README.md
```

## Getting Started

### Prerequisites

Make sure the following tools are installed:

- Git
- Node.js and npm
- Flutter SDK
- Dart SDK
- PostgreSQL-compatible database access

### Clone Repository

```bash
git clone https://github.com/JihanSanddw/JIRIS-JN.git
cd JIRIS-JN
```

### Backend Setup

```bash
cd backend
npm install
```

Configure the backend environment variables using the project's `.env` configuration.

Start the backend using the start command defined in `backend/package.json`.

### Mobile Application Setup

Open another terminal:

```bash
cd mobile
flutter pub get
flutter run
```

## Development Workflow

JIRIS uses a feature-based Git workflow.

| Branch                  | Purpose                        |
| ----------------------- | ------------------------------ |
| `main`                  | Main stable branch             |
| `develop`               | Development integration branch |
| `feature/backend-setup` | Backend development            |
| `feature/flutter-setup` | Flutter development            |
| `docs/update-readme`    | Repository documentation       |

### Commit Convention

Use descriptive commit messages:

- `feat:` — Add a new feature.
- `fix:` — Fix a bug.
- `docs:` — Documentation changes.
- `refactor:` — Code restructuring.
- `chore:` — Maintenance and configuration.

## Project Status

JIRIS is currently under active development.

The backend foundation, mobile application foundation, and initial integration between development branches have been established.

New features and improvements will be added progressively.

## Repository

GitHub: https://github.com/JihanSanddw/JIRIS-JN

---

**JIRIS — Discover Furniture, Create Your Space.**

## Environment Variables

The backend requires environment variables for database connectivity, image storage, authentication, and server configuration.

Create a `.env` file inside the `backend/` directory.

### Database Configuration

| Variable | Description |
|---|---|
| `DB_HOST` | PostgreSQL server hostname |
| `DB_PORT` | PostgreSQL server port |
| `DB_NAME` | Database name |
| `DB_USER` | Database username |
| `DB_PASSWORD` | Database password |
| `DB_CA_PATH` | Path to the PostgreSQL CA certificate |

### Cloudinary Configuration

| Variable | Description |
|---|---|
| `CLOUDINARY_CLOUD_NAME` | Cloudinary cloud name |
| `CLOUDINARY_API_KEY` | Cloudinary API key |
| `CLOUDINARY_API_SECRET` | Cloudinary API secret |

### Server Configuration

| Variable | Description |
|---|---|
| `PORT` | Backend server port (default: 3663) |

**Security Note:** Never commit `.env` files, database credentials, API secrets, or private certificates to a public repository.

## API Documentation

The JIRIS backend provides REST API endpoints organized into the following modules:

| Module | Base Endpoint |
|---|---|
| Authentication | `/api/auth` |
| Users | `/api/users` |
| Admin | `/api/admin` |
| Categories | `/api/categories` |
| Products | `/api/products` |
| Companies | `/api/companies` |
| Upload | `/api/upload` |
| Cart | `/api/cart` |
| Orders | `/api/orders` |

### Health Check

| Method | Endpoint | Description |
|---|---|---|
| GET | `/` | Check API availability |
| GET | `/db-test` | Test PostgreSQL database connection |

The database connection uses PostgreSQL SSL configuration with a CA certificate.

For endpoint details, request parameters, and response examples, refer to the backend route implementations.
