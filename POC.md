# Detailed Search Request Workflow (POC)

This section provides a granular, step-by-step breakdown of a single user search request, from the browser to the backend services and back.

### Architecture Overview (Request Path)

```text
User Browser → Apache/Nginx → Node.js Backend → Meilisearch
    ↑           |
    └───────────┘
   (Static Files)
```

### Detailed Request Flow Steps

#### 1. User Opens the Application

User navigates to: `https://example.com/customer-search-poc/`
1.  **Apache serves static files**
    *   Loads: `index.html`, `assets/*.js`, `assets/*.css`
2.  **React app initializes in browser**

#### 2. Frontend makes API call

The React application triggers a `fetch` request to the backend API endpoint.

```javascript
// In browser (customerService.ts)
fetch('/api/search?q=john&page=1')
```

#### 3. Browser sends HTTP request

The browser constructs and sends the full HTTP request to the web server.

```
GET https://example.com/api/search?q=john&page=1
```

#### 4. Apache/Nginx intercepts `/api/*` requests

The web server, acting as a reverse proxy, matches the `/api` path and forwards the request to the internal Node.js service.

```apacheconf
# Apache configuration (reverse proxy)
ProxyPass /api http://127.0.0.1:9000
ProxyPassReverse /api http://127.0.0.1:9000
```
This rewrites the request to: `GET http://127.0.0.1:9000/search?q=john&page=1`

#### 5. Node.js backend receives the request

The Express server receives the forwarded request and extracts the query parameters.

```javascript
// backend/src/app.ts
app.get("/search", async (req, res) => {
  const q = req.query.q;         // "john"
  const page = req.query.page;   // "1"
  // ...
})
```

#### 6. Backend queries Meilisearch

The backend makes a POST request to the Meilisearch search endpoint.

```javascript
const result = await axios.post('http://127.0.0.1:7700/indexes/customers/search', {
  q: "john",
  limit: 100,
  offset: 0
});
```

#### 7. Meilisearch returns results

Meilisearch processes the query and returns a JSON object with the matching documents.

```json
{
  "hits": [
    { "id": 1, "firstName": "John", "lastName": "Doe", "email": "john@example.com" },
    { "id": 2, "firstName": "Johnny", "lastName": "Smith", "email": "johnny@example.com" }
  ],
  "processingTimeMs": 5
}
```

#### 8. Backend formats and returns response

The Node.js backend formats the data from Meilisearch into a consistent API response structure.

```javascript
res.json({
  query: "john",
  page: 1,
  results: result.data.hits
});
```

#### 9. Response travels back through reverse proxy

The JSON response travels from the backend service back through the web server to the user's browser.
`Node.js (port 9000) → Apache → Browser`

#### 10. Frontend receives and displays results

The frontend code parses the JSON response and updates the application state.

```javascript
// customerService.ts
const data = await response.json();
// React state is updated with data.results, triggering a re-render
```
The `CustomerList` component re-renders with the new data, displaying the search results to the user.

---

## POC Component Breakdown

### Frontend (Static Files)

*   **Location:** `https://example.com/customer-search-poc/`
*   **Files:** `index.html`, `assets/*.js`, `assets/*.css`
*   **Built from:** `frontend/src/` (React + TypeScript)
*   **Build tool:** Vite (`npm run build` → `frontend/dist/`)

### Reverse Proxy (Apache/Nginx)

*   **Purpose:** Routes `/api/*` requests to the Node.js backend.
*   **Configuration:** Apache `VirtualHost` or nginx `server` block.

### Backend API (Node.js + Express)

*   **Location:** `http://127.0.0.1:9000`
*   **Process:** Managed by PM2 (`pm2 restart customer-search-api`).
*   **Files:** `backend/dist/app.js` (compiled from `backend/src/app.ts`).
*   **Build:** `npm run build` → `tsc` compiles TS to JS.

### Search Engine (Meilisearch)

*   **Location:** `http://127.0.0.1:7700`
*   **Index:** `customers`
*   **Purpose:** Fast full-text search.

---

## POC Deployment Checklist

1.  **Frontend:** Upload `frontend/dist/*` to the web root directory.
2.  **Backend:** Upload `backend/dist/*` and restart the PM2 process.
3.  **Reverse Proxy:** Ensure the `/api` → `http://127.0.0.1:9000` rule is configured and active.
4.  **Meilisearch:** Ensure the Meilisearch service is running and accessible on port `7700`.
