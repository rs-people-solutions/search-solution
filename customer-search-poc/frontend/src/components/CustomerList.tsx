import { Customer } from '../types/Customer';

interface CustomerListProps {
  customers: Customer[];
  loading: boolean;
  error: string | null;
}

export const CustomerList: React.FC<CustomerListProps> = ({
  customers,
  loading,
  error
}) => {
  if (loading) {
    return <div className="loading">Loading...</div>;
  }

  if (error) {
    return <div className="error">Error: {error}</div>;
  }

  if (customers.length === 0) {
    return <div className="no-results">No customers found</div>;
  }

  return (
    <div className="customer-list">
      <h2>Results ({customers.length})</h2>
      <ul>
        {customers.map((customer) => (
          <li key={customer.id} className="customer-item">
            <div className="customer-info">
              <strong>
                {customer.firstName} {customer.lastName}
              </strong>
              <span className="customer-id">ID: {customer.id}</span>
            </div>
            <div className="customer-email">
              {customer.email.map((email, index) => (
                <span key={index} className="email">
                  {email}
                </span>
              ))}
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
};