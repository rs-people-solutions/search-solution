# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Set an environment variable to ensure python output is sent straight to the terminal
ENV PYTHONUNBUFFERED 1

# Set the working directory in the container
WORKDIR /app

# Copy the dependencies file to the working directory
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the content of the local src directory to the working directory
COPY simulator.py .

# Expose the ports the app runs on
EXPOSE 8080
EXPOSE 5555

# Run the application using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "1", "--threads", "4", "simulator:app"]