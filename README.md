# bitcoin-wallet

This project uses the Phoenix framework with Elixir, running inside a Docker container along with a PostgreSQL database.

## Prerequisites

Make sure you have the following software installed on your machine:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)

## How to Run the Project

### 1. Clone the Repository

```sh
git clone https://github.com/Raul-gonc/bitcoin-wallet.git
cd bitcoin-wallet
```

### 2. Build the Containers

```sh
docker-compose build
```

### 3. Create the Database

```sh
docker-compose run --rm phoenix mix ecto.create
```

### 4. Start the Application

```sh
docker-compose up
```

The application will be available at:

```
http://localhost:4000
```

### 5. Stop the Containers

To stop the containers without removing them:

```sh
docker-compose stop
```

To stop and remove the containers, networks, and volumes:

```sh
docker-compose down -v
```

## Project Structure

- `docker-compose.yml` - Docker services configuration.
- `Dockerfile` - Phoenix development environment setup.
- `src/` - Phoenix application source code.


## Notes

- Ensure that port `4000` is not being used by another process.