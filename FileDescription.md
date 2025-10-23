
📖 Core File Breakdown: CRUD-App
================================

This document provides a detailed description of the core files responsible for building, configuring, and running the containerized Python/Flask CRUD application.

* * * * *

1\. `requirements.txt`
----------------------

This file lists all the Python libraries required by the application. When the Docker image is built, the `pip install` command uses this file to fetch dependencies.

### Key Dependencies

-   **`Flask`**: The micro-framework that powers the API.

-   **`gunicorn`**: A robust, production-ready **WSGI HTTP Server** used to run the application stably (instead of Flask's built-in development server).

-   **`Flask-SQLAlchemy`**: An extension that simplifies the use of **SQLAlchemy** (the Object-Relational Mapper) with Flask.

-   **`psycopg2-binary`**: The necessary adapter library (driver) that allows Python to connect and communicate with the **PostgreSQL** database.

### Content Example

```
Flask==2.3.3
gunicorn==21.2.0
psycopg2-binary==2.9.9
SQLAlchemy==2.0.21
Flask-SQLAlchemy==3.1.1

```

* * * * *

2\. `Dockerfile`
----------------

The `Dockerfile` is the blueprint for creating the final, runnable Docker image. It ensures the application environment is consistent everywhere it runs.

### Key Concepts

-   **Multi-Stage Build:** This technique uses two separate `FROM` statements to create two stages: a **`builder`** stage and a **`final`** stage.

    -   The **`builder`** stage installs system packages (`libpq-dev`, `gcc`) required to compile the `psycopg2` driver.

    -   The **`final`** stage starts from a smaller `python:3.11-slim` base and only copies the necessary compiled artifacts, resulting in a smaller, more secure production image.

-   **Working Directory (`WORKDIR`):** Sets the execution context inside the container (`/usr/src/app`).

-   **Exposed Port (`EXPOSE 3000`):** Documents the port on which the application listens internally.

-   **Entrypoint (`CMD`):** Specifies the command to execute when the container starts, launching the application via **Gunicorn** on port `3000`.

### Content (Described)

The Dockerfile first sets up the build environment, installs the system dependencies needed for `psycopg2`, installs Python packages, and finally copies the results to a small `slim` image for runtime.

* * * * *

3\. `app.py`
------------

This is the core Python file containing all the application logic, configuration, and API routes.

### Key Functions

-   **Configuration Management:** Uses the Python `os` module to read all critical settings (like database credentials and hostnames) from **environment variables** (`os.getenv()`). This is crucial for switching between the local **Docker Compose** setup and a production environment (like **Cloud Run**).

-   **Database Model:** Defines the `Item` class using **SQLAlchemy**, mapping Python objects to the PostgreSQL table structure (`id`, `name`, `description`).

-   **CRUD Endpoints:** Contains the four fundamental API functions mapped to the `/items` URL:

    -   `@app.route('/items', methods=['POST'])`: **Create**

    -   `@app.route('/items', methods=['GET'])`: **Read All**

    -   `@app.route('/items/<int:item_id>', methods=['GET'])`: **Read Single**

    -   `@app.route('/items/<int:item_id>', methods=['PUT'])`: **Update**

    -   `@app.route('/items/<int:item_id>', methods=['DELETE'])`: **Delete**

-   **Initial Setup:** Calls `db.create_all()` within an application context to automatically create the necessary `items` table in the PostgreSQL database on startup.

* * * * *

4\. `docker-compose.yml`
------------------------

This file is used **exclusively for local development and testing**. It orchestrates the multiple containers required to run the application as a single unit.

### Key Configuration

-   **Services:** Defines two services: `web` (the Flask application) and `db` (the PostgreSQL instance).

-   **Database Setup:** The `db` service uses the official `postgres:15-alpine` image and sets up default user/password/database names via `environment` variables.

-   **Host Mapping (`DB_HOST: db`):** Crucially, the `web` service uses the **service name** (`db`) as the hostname to connect to the database, leveraging Docker's internal networking.

-   **Volume Mounting (`volumes`):** The code directory is mounted into the container, allowing for **live code changes** without needing to rebuild the image (hot-reloading).

-   **Port Mapping (Updated):** The `ports` section is configured to map the internal application port **3000** to the host machine's standard HTTP port **80**.

### Port Mapping Detail

The line `"80:3000"` means:

-   When you navigate to `http://localhost:80` (or just `http://localhost`), your browser hits port **80** on your computer.

-   Docker forwards that request to port **3000** inside the **`web`** container, where the Flask application is running.

### Content Example (Focus on `web` service)

YAML

```
# ... (omitting version and db service for brevity)

services:
  web:
    build: .
    # Maps Host Port 80 to Container Port 3000
    ports:
      - "80:3000"
    volumes:
      - .:/usr/src/app
    environment:
      # ... database variables ...
      DB_HOST: db
    depends_on:
      - db
    command: python app.py
# ...
```
