# High Level Architecture

**Components:**

*   **Customer Database Simulator**
    *   Stores all customer records in-memory (or in a real DB in production).
    *   Generates initial dataset and continuously applies changes (CREATE, UPDATE, DELETE).
    *   Publishes change events via **pub/sub mechanism (ZeroMQ)**.

*   **Search Engine (Meilisearch)**
    *   Indexes customer data for full-text search.
    *   Supports search across `firstName`, `lastName`, and `email`.
    *   Automatically updates searchable fields when new events are received.

*   **Background Worker / Updater**
    *   Subscribes to database change events.
    *   Updates the Meilisearch index in near real-time.
    *   Ensures the `searchableName` and `email` fields are correctly indexed.

*   **API / Frontend**
    *   Receives search queries from users.
    *   Queries Meilisearch and returns results.

**Deployment:**

*   Customer database simulator → VM / container / serverless function
*   Meilisearch → VM / container (high availability in prod)
*   Background worker → separate process / container
*   API → Web server / container / serverless endpoint

# Data Flow

1.  **Search Request**
    1.  User sends query (e.g., `q=John`) to API.
    2.  API forwards query to Meilisearch.
    3.  Meilisearch searches indexed fields (`firstName`, `lastName`, `email`).
    4.  Search results are returned to the user.

2.  **Database Update**
    1.  Simulator modifies customer records (CREATE, UPDATE, DELETE).
    2.  Change event is published via pub/sub (topic: `dataChanges`).
    3.  Background worker subscribes to events:
        *   On **CREATE**: adds new customer to Meilisearch.
        *   On **UPDATE**: updates the existing record in Meilisearch.
        *   On **DELETE**: removes record from Meilisearch.
    4.  Meilisearch index remains up-to-date in near real-time.


<br>
<br>
<br>
<br>

**This diagram illustrates the interaction between the different components for both search requests and data synchronization.**

```mermaid
graph TD
    subgraph "User Interaction"
        User -- "1. Sends Search Query (q=John)" --> API
        API -- "4. Returns Search Results" --> User
    end

    subgraph "Core Services"
        API[API / Frontend] -- "2. Forwards Query" --> Meilisearch
        Meilisearch[🚀 Meilisearch Engine] -- "3. Searches Index" --> API
        Worker[🔧 Background Worker] -- "C. Updates Index (Add/Update/Delete)" --> Meilisearch
    end

    subgraph "Data Synchronization Backend"
        DB[👤 Customer Database Simulator] -- "A. Publishes Change Event" --> PubSub(ZMQ Pub/Sub)
        PubSub -- "B. Delivers Event" --> Worker
    end

    style DB fill:#d5f5e3
    style Meilisearch fill:#fdebd0
    style Worker fill:#eaf2f8
    style API fill:#eaf2f8    
