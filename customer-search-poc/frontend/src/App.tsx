import { useState, useCallback } from 'react';
import { CustomerService } from './services/customerService';
import { Customer } from './types/Customer';
import { SearchBox } from './components/SearchBox';
import { CustomerList } from './components/CustomerList';
import { Pagination } from './components/Pagination';
import './App.css';



function App() {
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [searchQuery, setSearchQuery] = useState('');

  const fetchCustomers = useCallback(async (query: string, page: number) => {
    setLoading(true);
    setError(null);

    try {
      const results = await CustomerService.searchCustomers(query, page);
      setCustomers(results);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load customers');
      setCustomers([]);
    } finally {
      setLoading(false);
    }
  }, []);

  const handleSearch = useCallback((query: string) => {
    setSearchQuery(query);
    setCurrentPage(1);
    fetchCustomers(query, 1);
  }, [fetchCustomers]);

  const handlePageChange = (page: number) => {
    if (page < 1) return;
    setCurrentPage(page);
    fetchCustomers(searchQuery, page);
  };

  // Initial load removed - search box will trigger with empty query on mount


  return (
    <div className="app">
      <header className="app-header">
        <h1>Customer Search</h1>
      </header>

      <main className="app-main">
        <div className="search-section">
          <SearchBox onSearch={handleSearch} />
        </div>

        <CustomerList
          customers={customers}
          loading={loading}
          error={error}
        />

        {!loading && !error && customers.length > 0 && (
          <Pagination
            currentPage={currentPage}
            onPageChange={handlePageChange}
            disabled={loading}
            hasMore={customers.length === 100}
          />
        )}
      </main>
    </div>
  );
}

export default App;