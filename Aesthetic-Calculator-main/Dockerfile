# Use an official lightweight Python image
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file first to leverage Docker caching
COPY requirements.txt .

# Install dependencies globally inside the container
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your webapp code
COPY . .

# Expose the port Flask runs on (change if your app uses a different port)
EXPOSE 5000

# Command to run the Flask application
CMD ["python", "main.py"]
