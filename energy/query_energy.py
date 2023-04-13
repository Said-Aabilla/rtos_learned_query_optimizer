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
SELECT to_char(now(), 'YYYY-MM-DD HH24:MI:SS') INTO startTime;
EXECUTE  $1 INTO executionPlan;
SELECT to_char(now(), 'YYYY-MM-DD HH24:MI:SS') INTO endTime;
RETURN startTime || ';' || executionPlan || ';' || endTime;
END;
$$ LANGUAGE plpgsql;
"""

def get_query_energy(query, cursor, force_order):
    cursor.execute("set max_parallel_workers=1;")
    cursor.execute("set max_parallel_workers_per_gather = 1;")
    cursor.execute("set geqo_threshold = 20;")

    # Prepare query
    join_collapse_limit = "SET join_collapse_limit ="
    join_collapse_limit += "1" if force_order else "8"
    query = join_collapse_limit + "; EXPLAIN  " + query + ";"

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
    endExecTime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    result = cursor.fetchone()
    result = result[0].split(";")
    (startTime, executionPlan, endTime) = (result[0], result[1], endExecTime)

    # print("4-4 - is recording: ", psensor.get_dataLogger().get_recording())
    print("startTime: ", startTime, " - endTime: ", endTime)
    # YAPI.Sleep(2000)
    time.sleep(2.0)
    print("stop recording : ", datetime.now())
    stopDataRecording(psensor)
    print("7 - is recording: ", psensor.get_dataLogger().get_recording())

    (power, exec_time, energy) = getAveragePower(psensor, startTime, endTime)


    return (power, exec_time, energy)


if __name__ == "__main__":
    conn, cursor = connect_bdd("imdbload")
    with open('./JOB-job_extended_queries/29b.sql', 'r') as file:
    # with open('./energy/output.txt', 'r') as file:
        # Read the contents of the file into a string variable
        query = file.read()

    get_query_energy(query, cursor, False)
