import csv
import os
import time

import psycopg2

from energy_functions import *


def connect_bdd(name):
    conn = psycopg2.connect(host="localhost",
                            user="postgres", password="postgres",
                            database=name)
    cursor = conn.cursor()
    return [conn, cursor]


"""
CREATE OR REPLACE FUNCTION getQueryExecutionInfo(text) RETURNS text AS $$
DECLARE
startTime text;
endTime text;
executionPlan text;
insertedId int;
BEGIN
SELECT to_char(now(), 'YYYY-MM-DD HH24:MI:SS.MS') INTO startTime;
EXECUTE  $1 INTO executionPlan;
SELECT to_char(now(), 'YYYY-MM-DD HH24:MI:SS.MS') INTO endTime;
RETURN startTime || ';' || executionPlan || ';' || endTime;
END;
$$ LANGUAGE plpgsql;
"""

def get_query_exec_energy(cursor, query, force_order):
    # conn, cursor = connect_bdd("stack")

    cursor.execute("set max_parallel_workers=1;")
    cursor.execute("set max_parallel_workers_per_gather = 1;")

    # Prepare query
    join_collapse_limit = "SET join_collapse_limit ="
    join_collapse_limit += "1" if force_order else "8"
    query = join_collapse_limit + "; EXPLAIN Analyse " + query + ";"

    # Prepare sensor
    psensor = findPowerSensor("YWATTMK1-1F6860.power")
    stopDataRecording(psensor)
    clearPowerMeterCache(psensor)
    tm = time.time()
    datalog = psensor.get_dataLogger()
    datalog.set_timeUTC(time.time())
    startDataRecording(psensor)  # Power Meter starts recording power per second
    time.sleep(2.0)
    print("4 - is recording: ", psensor.get_dataLogger().get_recording())

    # execute query
    cursor.callproc('getQueryExecutionInfo', (query,))
    endExecTime = datetime.now().strftime("%Y-%m-%d %H:%M:%S:%f")

    result = cursor.fetchone()
    result = result[0].split(";")
    (startTime, executionPlan, endTime) = (result[0].replace(".", ":"), result[1], endExecTime)

    # print("4-4 - is recording: ", psensor.get_dataLogger().get_recording())
    print("startTime: ", startTime, " - endTime: ", endTime)
    # YAPI.Sleep(2000)
    time.sleep(2.0)
    print("stop recording : ", datetime.now())
    stopDataRecording(psensor)
    print("7 - is recording: ", psensor.get_dataLogger().get_recording())

    (power, exec_time, energy) = getAveragePower(psensor, startTime, endTime)

    return (power, exec_time, energy)



def get_query_latency(query, cursor, force_order):
    join_collapse_limit = "SET join_collapse_limit ="
    join_collapse_limit += "1;" if force_order else "8;"
    cursor.execute(join_collapse_limit)

    # Prepare query

    query = " EXPLAIN  ANALYSE " + query

    cursor.execute(query)

    rows = cursor.fetchall()
    row = rows[0][0]
    latency = float(rows[0][0].split("actual time=")[1].split("..")[1].split(" ")[0])

    return latency


if __name__ == "__main__":

    conn, cursor = connect_bdd("stack")
    algo_metadata = {}
    # Set the path to the directory containing the files
    directory_path = "../workload/rtos-stack-solutions"

    index = 0
    # Loop over all the files in the directory
    for filename in os.listdir(directory_path) :
        index = index +1
        # Check if the file is a file and not a directory
        if os.path.isfile(os.path.join(directory_path, filename)) and index < 113: # and filename in elements:

            # Open the file for reading
            with open(os.path.join(directory_path, filename), 'r') as file:
                # Read the contents of the file
                query = file.read()
                print(filename)
                algo_metadata[filename] = []

                power, exec_time, pg_energy = get_query_exec_energy(cursor,query,  False)
                power_2, exec_time_2, rtos_energy = get_query_exec_energy(cursor,query, True)

                pg_latency = get_query_latency(query, cursor, False)
                rtos_latency = get_query_latency(query, cursor, True)

                # energy_tot.append(energy)
                # latency_tot[filename] = latency
                print(pg_latency)
                print(rtos_latency)
                algo_metadata[filename].append(pg_latency)
                algo_metadata[filename].append(pg_energy)
                algo_metadata[filename].append(rtos_latency)
                algo_metadata[filename].append(rtos_energy)
                # print("energy : ",energy_tot)
        print("----------------------------------------------------------")
    print("saving csv")
    # open a CSV file for writing
    with open('stack_rtos_latency.csv', 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)

        # write the header row
        writer.writerow(['Filename', 'pg_latency', 'rtos_latency', 'pg_energy', 'rtos_energy'])
        for filename, data in algo_metadata.items():
            writer.writerow([filename, data[0], data[2], data[1], data[3]])

    print("-----------------------------")
