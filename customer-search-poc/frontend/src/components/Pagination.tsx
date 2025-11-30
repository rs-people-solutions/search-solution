interface PaginationProps {
  currentPage: number;
  onPageChange: (page: number) => void;
  disabled?: boolean;
  hasMore: boolean;
}

export const Pagination: React.FC<PaginationProps> = ({
  currentPage,
  onPageChange,
  disabled,
  hasMore
}) => {
  return (
    <div className="pagination">
      <button
        onClick={() => onPageChange(currentPage - 1)}
        disabled={disabled || currentPage <= 1}
      >
        Previous
      </button>
      <span className="page-number">Page {currentPage}</span>
      <button
        onClick={() => onPageChange(currentPage + 1)}
        disabled={disabled || !hasMore}
      >
        Next
      </button>
    </div>
  );
};