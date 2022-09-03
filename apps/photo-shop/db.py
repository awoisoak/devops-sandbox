import mysql.connector, utils
from mysql.connector import errorcode

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
            print("awoo:",Name, Price, ImageUrl)

        cursor.close()
    except mysql.connector.Error as err:
        utils.printError("Error connecting to the db :(")
    else:
        utils.printSuccess("Connection success! :)")
        cnx.close()