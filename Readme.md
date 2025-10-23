CRUD-App: Python/Flask RESTful API 🐍
=====================================

Project Overview
----------------

This is a fully containerized **C**reate, **R**ead, **U**pdate, **D**elete (CRUD) application built with **Python** and the **Flask** micro-framework. It is designed for simplicity, consistency, and ease of use for developers of all skill levels.

### Key Features

-   **Backend:** Python 3.11, Flask, Gunicorn.

-   **Database:** **PostgreSQL** for robust data persistence.

-   **ORM:** **SQLAlchemy** (via Flask-SQLAlchemy) manages database interactions.

-   **Containerized:** Uses **Docker** and **Docker Compose** for a single-command local setup.

-   **API:** Provides a RESTful JSON API for item management.

* * * * *

🚀 Getting Started
------------------

This project is entirely dependent on Docker for local development.

### Prerequisites

Ensure you have the following installed:

1.  **Docker Engine** (or Docker Desktop)

2.  **Docker Compose** (usually included with Docker Desktop)

### Local Setup

Follow these steps to build and run the application locally:

1.  **Clone the Repository:**

    Bash

    ```
    git clone [YOUR_REPO_URL]
    cd crud-app

    ```

2.  Start the Services (Web App + Database):

    This command builds the application image and starts both the Flask app and the PostgreSQL container, handling all networking and configuration automatically.

    Bash

    ```
    docker compose up --build

    ```

    *Note: The first time, this process includes installing `psycopg2` dependencies (like `libpq-dev`), so it will take a few minutes.*

3.  Access the API:

    The application will be accessible via your host machine's standard HTTP port:

    http://localhost (or http://localhost:80)

* * * * *

📂 Project Structure and File Guide
-----------------------------------

| **File Name** | **Description** | **Purpose** |
| --- | --- | --- |
| **`app.py`** | **Application Core** | Configures **SQLAlchemy** to connect to PostgreSQL using environment variables. Defines the **`Item`** model and implements all four **CRUD routes** (`POST`, `GET`, `PUT`, `DELETE`). |
| **`requirements.txt`** | **Python Dependencies** | Lists all required packages: `Flask`, production server **`gunicorn`**, ORM **`Flask-SQLAlchemy`**, and the PostgreSQL connector **`psycopg2-binary`**. |
| **`Dockerfile`** | **Image Definition** | Uses a **multi-stage build** approach to keep the final image size small. It ensures necessary system packages for `psycopg2` are installed during the build stage. |
| **`docker-compose.yml`** | **Local Environment** | Defines the two-service architecture (`web` and `db`). It handles port mapping (`80:5000`) and securely injects the required database credentials (e.g., `DB_HOST: db`) into the Flask app container. |
| **`.dockerignore`** | **Build Optimization** | Prevents unnecessary files (like `.git` and `venv/`) from being copied into the Docker build context, speeding up the build process. |

* * * * *

⚙️ API Usage & Testing
----------------------

The application exposes the `/items` resource. You can use `curl` or any API client to test the endpoints.

| **Method** | **Endpoint** | **Operation** | **Body Required?** | **Example curl Command** |
| --- | --- | --- | --- | --- |
| **POST** | `/items` | Create | **Yes** (JSON: `name`, `description`) | `curl -X POST -H "Content-Type: application/json" -d '{"name": "Book"}' http://localhost/items` |
| **GET** | `/items` | Read All | No | `curl http://localhost/items` |
| **GET** | `/items/{id}` | Read Single | No | `curl http://localhost/items/1` |
| **PUT** | `/items/{id}` | Update | **Yes** (JSON: fields to update) | `curl -X PUT -H "Content-Type: application/json" -d '{"description": "Updated Book"}' http://localhost/items/1` |
| **DELETE** | `/items/{id}` | Delete | No | `curl -X DELETE http://localhost/items/1` |

* * * * *

🛠 Development Notes
--------------------

### Database Connection

The application is configured using the following environment variables, which are set in `docker-compose.yml` for the local environment:

-   `DB_HOST: db` (The name of the database service)

-   `DB_USER: user`

-   `DB_PASS: password`

-   `DB_NAME: cruddb`

### Stopping the Stack

To gracefully stop the containers:

Bash

```
docker compose down

```

To also remove the persistent database volume (deleting all your stored data), use the `-v` flag:

Bash

```
docker compose down -v

```

* * * * *

☁️ Production Deployment (Next Steps)
-------------------------------------

This containerized setup directly addresses ticket **CRUD-5678**.

The primary difference for production deployment will be how the database is handled:

1.  **Managed Database:** The `db` service should be replaced by a **Managed Database Service** (e.g., AWS RDS, GCP Cloud SQL) for stability, backups, and scaling.

2.  **Secrets Management:** Sensitive credentials (`DB_USER`, `DB_PASS`) must be stored and injected via a **Secret Manager** (e.g., AWS Secrets Manager, GCP Secret Manager) into the deployment service (e.g., Google Cloud Run), instead of being listed directly in configuration files or CLI commands.

3.  **Deployment Target:** The image can be deployed to a **Serverless Container Platform** like **Google Cloud Run** or **AWS Fargate** for automated scaling and reduced operational overhead.
