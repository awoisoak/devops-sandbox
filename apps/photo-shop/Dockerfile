# To build the container:
#   docker build . -t awoisoak/photo-shop
# To run it directly from docker hub:
#   docker run -p 9000:9000 --network photo-network -ti awoisoak/photo-shop

# Force platform to avoid issues with Apple silicon processors
FROM --platform=linux/amd64 ubuntu

# Install dependencies
RUN apt update
RUN apt install python3 -y
RUN apt install python3-pip -y
RUN apt install curl -y
RUN apt install mysql-client -y
RUN apt install libmysqlclient-dev -y

# Copy source code to working directory
COPY . /opt/photo_shop

# Set the working directory
WORKDIR /opt/photo_shop

# Install the dependencies and packages in the requirements file
RUN pip install -r requirements.txt

# Flask will expose port 9000 for the website
EXPOSE 9000

# Run Flask webserver. -u flag to force unbuffered output
ENTRYPOINT [ "python3", "-u" ]
CMD ["app.py" ]
