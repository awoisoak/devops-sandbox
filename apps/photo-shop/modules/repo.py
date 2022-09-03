import os, mysql.connector, modules.utils as utils
from mysql.connector import errorcode

# Conects to the database (running in another container) and grab the data
def connect_db():
    try:
        # Database information (including hostname and name) is defined in docker-compose file
        cnx = mysql.connector.connect(user='root', password='password',
                                    host='db',
                                    database='photosdb')

        cursor = cnx.cursor()
        query = ("SELECT * from photos")
        cursor.execute(query)

        for (id, Name, Price, ImageUrl) in cursor:
            print("awo:",Name, Price, ImageUrl)

        cursor.close()
    except mysql.connector.Error as err:
        utils.printError("Error connecting to the db :(")
    else:
        utils.printSuccess("Connection success! :)")
        cnx.close()

# Get the list of images directly from the local directory
def getLocalImages():
    image_names = os.listdir('./images')        