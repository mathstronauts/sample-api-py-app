FROM --platform=linux/amd64 python:3.8-slim-buster AS build

# Copy the current directory contents into the container at /app
COPY . /app

# Set the working directory to /app
WORKDIR /app

# install dependencies from setup.py
RUN python -m pip install -r requirements.txt

# Expose the port the app runs on
EXPOSE 8000

# Run the application
CMD ["uvicorn", "src.app:app", "--host=0.0.0.0"]