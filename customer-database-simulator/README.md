# HackMotion homework customer database simulator

The service simulates a customer database system with a paginated API and a real-time message queue for data change notifications.

The service periodically makes data changes - updates, creation and deletion of records.

# How to run

Follow these steps to set up the simulator and the Meilisearch database.

## Prerequisites

- **Python 3.12+**
- **Docker** (for running Meilisearch)

## Step-by-Step Setup

### 1. Install Dependencies

Create a virtual environment and install the required Python packages.

```bash
# Create virtual environment
python -m venv .venv

# Activate virtual environment
# Windows:
.venv\Scripts\activate
# Linux/Mac:
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Start Meilisearch

Run Meilisearch using Docker. This command starts a Meilisearch instance on port `7700`.

```bash
docker run -it --rm -p 7700:7700 -v meili_data:/meili_data getmeili/meilisearch:v1.11
```

### 3. Initialize the Database

Run the `index_customers.py` script.
**Note:** This script imports the data generation logic from `simulator.py` to populate Meilisearch, but it **does not** start the API or the background simulation. It only indexes the initial dataset.

```bash
# Make sure your virtual environment is activated
python index_customers.py
```

You should see output indicating that customers have been indexed.

### 4. Run the Simulator

To start the API (`http://localhost:8080`) and the real-time data changes (ZeroMQ on port `5555`), you must run `simulator.py`.

```bash
# Make sure your virtual environment is activated
python simulator.py
```

### Alternative: Run Simulator with Docker

If you prefer, you can run the simulator using the provided `Dockerfile`.

1.  **Build the image:**
    ```bash
    docker build -t backend-simulator .
    ```

2.  **Run the container:**
    ```bash
    docker run -p 8080:8080 -p 5555:5555 --rm backend-simulator
    ```

**Note:** You still need to run `index_customers.py` locally (Step 3) to populate the database, as the Docker image only runs the simulator service.

# Details

The container exposes an HTTP based API and a ZeroMQ message queue.

## `GET /customers?page=XXX`

The API simulates a slow, paginated endpoint for fetching all customer records. Returns 1000 records per page. Has an artificial 1-second delay per request. Records are sorted by ID, descending.

The response is a JSON list consisting of objects with this schema.

```json
{
  "id": 123,
  "firstName": "John",
  "lastName": "Doe",
  "email": ["john.doe@example.com"]
}
```

## ZeroMQ message queue

The message queue is exposed on port `5555`.

The message queue publishes events to a topic called `dataChanges` whenever customer data is modified in the simulator (roughly every 10 seconds).

The message published to the `dataChanges` topic is a JSON object describing the event. The data field contains the **full** customer record - therefore, for `UPDATE` events, it represents the final state of the record.
For `DELETE` events, only `id` is provided.

```json
{
  "eventType": "CREATE" or "UPDATE" or "DELETE",
  "data": {
    "id": 456,
    "firstName": "Jane",
    "lastName": "Smith",
    "email": ["jane.s@example.com"]
  }
}
```

# Deployment (Linux/Systemd)

For production-like environments, systemd service files are provided in the `services/` directory.

1.  **`meilisearch.service`**: Runs the Meilisearch server.
2.  **`customer-simulator.service`**: Runs the Flask API and simulator.
3.  **`zmq-to-meilisearch.service`**: Runs the sync worker.

**Note:** You will likely need to edit the `WorkingDirectory`, `ExecStart`, and `Environment` paths in these files to match your actual installation directory.

Example installation:
```bash
sudo cp services/*.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now meilisearch
sudo systemctl enable --now customer-simulator
sudo systemctl enable --now zmq-to-meilisearch
```