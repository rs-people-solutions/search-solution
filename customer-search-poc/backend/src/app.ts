import express, { Request, Response } from "express";
import axios from "axios";
import cors from "cors";
import { SearchResult, ErrorResponse } from "./types";

const app = express();
const PORT = 9000;

app.use(cors());
app.use(express.json());

const MEILI_URL = "http://127.0.0.1:7700";

app.get("/search", async (req: Request, res: Response) => {
  const q = (req.query.q as string) || "";

  const page = parseInt(req.query.page as string) || 1;
  const limit = 100;
  const offset = (page - 1) * limit;

  try {
    const result = await axios.post(`${MEILI_URL}/indexes/customers/search`, {
      q: q.trim(),
      limit,
      offset,
      sort: ["id:desc"]
    });

    res.json({
      query: q,
      page: page,
      results: result.data.hits
    } as SearchResult);
  } catch (err) {
    const errorMessage = err instanceof Error ? err.message : "Unknown error";
    res.status(500).json({
      error: "Meilisearch error",
      detail: errorMessage
    } as ErrorResponse);
  }
});

app.listen(PORT, () => {
  console.log(`Node.js POC app running at http://127.0.0.1:${PORT}`);
});