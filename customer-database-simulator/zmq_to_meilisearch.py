import zmq
import json
from meilisearch import Client

# --- Meilisearch setup ---
client = Client('http://127.0.0.1:7700')
index = client.index('customers')

# --- ZMQ subscriber setup ---
context = zmq.Context()
socket = context.socket(zmq.SUB)
socket.connect("tcp://127.0.0.1:5555")
socket.setsockopt_string(zmq.SUBSCRIBE, 'dataChanges')

print("Listening for customer database changes...")

while True:
    topic, message = socket.recv_multipart()
    event = json.loads(message)
    etype = event['eventType']
    data = event['data']

    # --- Clean data to only include the fields we want ---
    cleaned_data = {
        "id": data.get("id"),
        "firstName": data.get("firstName"),
        "lastName": data.get("lastName"),
        "email": data.get("email") or []
    }

    if etype in ['CREATE', 'UPDATE']:
        index.add_documents([cleaned_data])
        print(f"{etype} {cleaned_data['id']} indexed")
    elif etype == 'DELETE':
        index.delete_document(cleaned_data['id'])
        print(f"DELETE {cleaned_data['id']} removed")
