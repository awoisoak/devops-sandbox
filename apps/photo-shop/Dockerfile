# The container can be run directly from docker hub
# ex) docker run -p 9000:9000 -ti awoisoak/photo-shop

# Force platform to avoid issues with Apple silicon processors
FROM --platform=linux/amd64 ubuntu

# Install dependencies
RUN apt update
RUN apt install python3 -y
RUN apt install python3-pip -y
RUN apt install curl -y

# Copy source code to working directory
COPY . /opt/photo_shop

# Set the working directory
WORKDIR /opt/photo_shop

# Install the dependencies and packages in the requirements file
RUN pip install -r requirements.txt

# Flask will expose port 9000 for the website
EXPOSE 9000

# Run Flask webserver
ENTRYPOINT [ "python3" ]
CMD ["app.py" ]
