import { useState, useEffect, useRef } from 'react';

interface SearchBoxProps {
  onSearch: (query: string) => void;
  disabled?: boolean;
}

export const SearchBox: React.FC<SearchBoxProps> = ({ onSearch, disabled }) => {
  const [query, setQuery] = useState('');
  const inputRef = useRef<HTMLInputElement>(null);

  // Auto-focus on mount
  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  // Debounced search effect
  useEffect(() => {
    const timer = setTimeout(() => {
      onSearch(query.trim());
    }, 400); // 400ms debounce delay

    return () => clearTimeout(timer);
  }, [query, onSearch]);

  return (
    <div className="search-box">
      <input
        ref={inputRef}
        type="text"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Type-in to search customers ..."
        disabled={disabled}
        className="search-input"
        autoFocus
      />
    </div>
  );
};