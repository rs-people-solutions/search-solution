export interface Customer {
  id: number;
  firstName: string;
  lastName: string;
  email: string[];
}

export interface SearchResponse {
  hits: Customer[];
  query: string;
  processingTimeMs: number;
  limit: number;
  offset: number;
  estimatedTotalHits: number;
}

export interface SearchResult {
  query: string;
  page?: number;
  results: any[];
}

export interface ErrorResponse {
  error: string;
  detail?: string;
}