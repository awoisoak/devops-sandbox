import os, mysql.connector, modules.utils as utils
from queue import Empty
from mysql.connector import errorcode
from pathlib import Path



# Attempt to get the list of images from the Database, 
# if it can't connect it will grab them from local directory
def getImages():
    images = __getDbImages()
    if images:
        utils.printWarning ("images retrieved from DB")
        return images
    else:
        utils.printWarning ("images retrieved locally")
        return __getLocalImages()    


# Get the list of images from the database (which runs in another container)
def __getDbImages():
    imageUrls = []
    try:
        # Database information (including hostname and name) is defined in docker-compose file
        cnx = mysql.connector.connect(user='root', password='password',
                                    host='db',
                                    database='photosdb')

        cursor = cnx.cursor()
        query = ("SELECT image_url from photos")
        cursor.execute(query)

        imageUrls = [row[0] for row in cursor.fetchall()]

        cursor.close()
    except mysql.connector.Error as err:
        utils.printError("Error connecting to the db :(")
        utils.printError(err.msg)
    else:
        utils.printSuccess("Connection success! :)")
        cnx.close()
    print(imageUrls)
    return imageUrls    

# Get the list of images directly from the local directory
def __getLocalImages():
    return utils.filterImages(os.listdir('./images'))     