import time
import mysql.connector
import csv


QUERY="""
INSERT INTO INCIDENTS (
    IncidentNumber,
    DateOfCall ,
    CalYear ,
    TimeOfCall ,
    HourOfCall ,
    IncidentGroup ,
    StopCodeDescription ,
    SpecialServiceType,
    PropertyCategory,
    PropertyType,
    AddressQualifier,
    Postcode_full,
    Postcode_district,
    UPRN,
    USRN,
    IncGeo_BoroughCode,
    IncGeo_BoroughName,
    ProperCase,
    IncGeo_WardCode,
    IncGeo_WardName,
    IncGeo_WardNameNew,
    Easting_m,
    Northing_m,
    Easting_rounded,
    Northing_rounded,
    FRS,
    Longitude,
    Latitude
    IncidentStationGround,
    FirstPumpArriving_AttendanceTime,
    FirstPumpArriving_DeployedFromStation,
    SecondPumpArriving_AttendanceTime,
    SecondPumpArriving_DeployedFromStation,
    NumStationsWithPumpsAttending,
    NumPumpsAttending,
    PumpCount)
    VALUES (%s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s);
"""


def main():
    path_to_files = "datasets/"
    mydb = mysql.connector.connect(
        host="localhost",
        user="root",
        password="debezium",
        database="demo"
    )

    mycursor = mydb.cursor()
    mycursor.execute("TRUNCATE TABLE INCIDENTS;")

    with open(path_to_files+'data.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        line_count = 0
        for row in csv_reader:
            if line_count == 0:
                print(f'Column names are {", ".join(row)}')
                line_count += 1
            else:
                row = [0 if i is None or i == 'NULL' else i for i in row]
                row = row[:-1]
                print(f'IncidentStationGround: {row[0]}')
                mycursor.execute(QUERY, row)
                mydb.commit()
                line_count += 1
            time.sleep(5)
        mycursor.close()
        mydb.close()

        print(f'Processed {line_count} lines.')


if __name__ == "__main__":
    main()
