# LittleWeb

LittleWeb is a Ruby-based web application designed for secure document access and rendering. It utilizes Asciidoctor for document processing and features a custom authentication system including TOTP support.

## Project Structure

- `src/`: Core Ruby source code.
  - `authentication/`: Logic for handling tokens and TOTP.
  - `crypto/`: Cryptographic utilities.
  - `database/`: Database interaction (SQLite3).
  - `doc_renderer/`: Asciidoctor rendering logic.
  - `http/`: Custom HTTP/Web server components (Request, Response, Controller, Filter).
  - `secure_access/`: Main application logic for secure access, including controllers and views (Slim templates).
- `docker/`: Dockerfiles and configurations for Nginx and Ruby FastCGI.
- `db/`: Database storage.

## Key Technologies

- **Language:** Ruby
- **Rendering:** Asciidoctor, Slim
- **Database:** SQLite3
- **Authentication:** TOTP (ROTP), Custom Tokens
- **Containerization:** Docker, Docker Compose
- **Web Server:** Nginx (Front-end), fcgiwrap (Ruby integration)
- **Email:** Mailhog (Development testing)

## Getting Started

### Prerequisites

- Docker and Docker Compose

### Running the Application

1. Build and start the containers:
   ```bash
   docker-compose up --build
   ```
2. The application should be accessible at `http://localhost:8080`.
3. Mailhog (for email testing) is available at `http://localhost:8025`.

## Development

### Running Tests

The default rake task runs the main application file, which likely contains some self-tests or starts the application in a specific mode.
```bash
rake
```

### Linting

RuboCop is used for code style enforcement.
```bash
cd src
bundle exec rubocop
```
