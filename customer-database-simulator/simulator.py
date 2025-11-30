import json
import random
import threading
import time
import zmq
from faker import Faker
from flask import Flask, jsonify, request

# --- Configuration ---
NUM_RECORDS = 100_000
PAGE_SIZE = 1_000
API_LATENCY_SECONDS = 1
CHANGE_INTERVAL_SECONDS = 10
ZMQ_PORT = 5555
API_PORT = 8080

# --- In-memory "Database" ---
customers_data = []
data_lock = threading.Lock()
# Start IDs after the initial batch
next_customer_id = NUM_RECORDS + 1

# --- Flask App Initialization ---
app = Flask(__name__)

# --- ZeroMQ Publisher Setup ---
#context = zmq.Context()
#zmq_socket = context.socket(zmq.PUB)
#zmq_socket.bind(f"tcp://*:{ZMQ_PORT}")
#print(f"ZeroMQ publisher running on port {ZMQ_PORT}")


def generate_initial_data():
    """Generates a list of 100,000 customer records."""
    print(f"Generating {NUM_RECORDS} initial customer records...")
    fake = Faker()
    data = []
    for i in range(1, NUM_RECORDS + 1):
        record_type = random.choice(['full', 'partial', 'id_only'])
        record = {"id": i, "firstName": None, "lastName": None, "email": []}

        if record_type == 'full':
            record["firstName"] = fake.first_name()
            record["lastName"] = fake.last_name()
            record["email"] = [fake.email()]
        elif record_type == 'partial':
            if random.choice([True, False]):
                record["firstName"] = fake.first_name()
            else:
                record["lastName"] = fake.last_name()
            record["email"] = [fake.email()]

        data.append(record)
    print("Data generation complete.")
    return data

@app.route('/customers', methods=['GET'])
def get_customers():
    """Serves paginated customer data with simulated latency."""
    try:
        page = int(request.args.get('page', 1))
    except (ValueError, TypeError):
        page = 1

    # Simulate network/database latency
    time.sleep(API_LATENCY_SECONDS)

    with data_lock:
        # Newest records first, so we reverse the list for slicing
        reversed_data = customers_data[::-1]
        start_index = (page - 1) * PAGE_SIZE
        end_index = start_index + PAGE_SIZE
        
        paginated_data = reversed_data[start_index:end_index]

    return jsonify(paginated_data)

def data_modification_task():
    """
    Periodically modifies the customer data and publishes changes to ZeroMQ.
    Runs in a background thread.
    """
    global customers_data, next_customer_id
    fake = Faker()

    while True:
        time.sleep(CHANGE_INTERVAL_SECONDS)
        
        with data_lock:
            action = random.choice(['CREATE', 'UPDATE', 'DELETE'])
            event = None

            if action == 'CREATE':
                new_customer = {
                    "id": next_customer_id,
                    "firstName": fake.first_name(),
                    "lastName": fake.last_name(),
                    "email": [fake.email()]
                }
                customers_data.append(new_customer)
                event = {"eventType": "CREATE", "data": new_customer}
                print(f"📢 CREATED customer {next_customer_id}")
                next_customer_id += 1

            elif action == 'UPDATE' and customers_data:
                customer_to_update = random.choice(customers_data)
                # Create a copy to modify
                updated_data = customer_to_update.copy()
                updated_data["firstName"] = fake.first_name() # Simulate a name change
                
                # Find index and update in the main list
                for i, customer in enumerate(customers_data):
                    if customer["id"] == updated_data["id"]:
                        customers_data[i] = updated_data
                        break
                
                event = {"eventType": "UPDATE", "data": updated_data}
                print(f"📢 UPDATED customer {updated_data['id']}")

            elif action == 'DELETE' and len(customers_data) > (NUM_RECORDS * 0.9): # Avoid deleting too many
                customer_to_delete = random.choice(customers_data)
                customers_data.remove(customer_to_delete)
                event = {"eventType": "DELETE", "data": {"id": customer_to_delete["id"]}}
                print(f"📢 DELETED customer {customer_to_delete['id']}")

            if event:
                # Publish to ZeroMQ: [topic] [json_payload]
                topic = b'dataChanges'
                payload = json.dumps(event).encode('utf-8')
                zmq_socket.send_multipart([topic, payload])


# Generate the initial dataset
customers_data = generate_initial_data()

if __name__ == "__main__":
    # ZeroMQ Publisher Setup
    context = zmq.Context()
    zmq_socket = context.socket(zmq.PUB)
    zmq_socket.bind(f"tcp://*:{ZMQ_PORT}")
    print(f"ZeroMQ publisher running on port {ZMQ_PORT}")

    # Background thread for data modifications
    modifier_thread = threading.Thread(target=data_modification_task, args=(zmq_socket,), daemon=True)
    modifier_thread.start()

    # Start Flask API server
    print(f"Flask API server starting on port {API_PORT}")
    app.run(host='0.0.0.0', port=API_PORT)
