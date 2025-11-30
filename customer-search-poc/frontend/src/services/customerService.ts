import { Customer } from '../types/Customer';

const API_BASE_URL = '/api';

export interface SearchResponse {
  query: string;
  results: Customer[];
}

export class CustomerService {
  /**
   * Search for customers by query term (or list all if query is empty)
   */
  static async searchCustomers(query: string, page: number = 1): Promise<Customer[]> {
    // Allow empty query for "view all" functionality
    const response = await fetch(
      `${API_BASE_URL}/search?q=${encodeURIComponent(query)}&page=${page}`
    );

    let results: Customer[] = [];

    if (response.ok) {
      const data: SearchResponse = await response.json();
      results = data.results || [];
    } else {
      const error = await response.json();
      throw new Error(error.error || 'Search failed');
    }

    return results;
  }
}