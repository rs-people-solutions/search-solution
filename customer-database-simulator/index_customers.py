from meilisearch import Client
from simulator import customers_data

# --- Connect to Meilisearch ---
client = Client('http://127.0.0.1:7700')
index = client.index('customers')

# --- Prepare customer data ---
valid_customers = []
for customer in customers_data:
    # Check if record is effectively empty (no name, no email)
    has_first_name = bool(customer.get("firstName"))
    has_last_name = bool(customer.get("lastName"))
    has_email = bool(customer.get("email") and len(customer["email"]) > 0)
    
    # Skip if all identifying fields are missing
    if not has_first_name and not has_last_name and not has_email:
        continue

    # Normalize fields
    customer["firstName"] = customer.get("firstName") or ""
    customer["lastName"] = customer.get("lastName") or ""
    # Create internal field for search, not for display
    customer["_searchableName"] = f"{customer['firstName']} {customer['lastName']}".strip()
    
    valid_customers.append(customer)

# --- Index valid documents ---
# Clear existing documents first to remove the empty ones
index.delete_all_documents()
index.add_documents(valid_customers)
print(f"Indexed {len(valid_customers)} valid customers in Meilisearch (skipped {len(customers_data) - len(valid_customers)} empty records)")

# --- Configure searchable attributes, ranking, and displayed attributes ---
index.update_settings({
    "searchableAttributes": ["firstName", "lastName", "_searchableName", "email"],
    "rankingRules": ["words", "typo", "proximity", "attribute", "exactness"],
    "displayedAttributes": ["id", "firstName", "lastName", "email"]  # hide _searchableName
})

print("Meilisearch settings updated.")

