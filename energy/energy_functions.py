import re

import psycopg2
from yoctopuce.yocto_power import *
from datetime import datetime, timedelta
import time


def findPowerSensor(power_sensor_identifier):
    errmsg = YRefParam()
    # Setup the API to use local USB devices
    if YAPI.RegisterHub("usb", errmsg) != YAPI.SUCCESS:
        print("init error " + errmsg.value)
        return None

    psensor = YPower.FindPower(power_sensor_identifier);
    if not psensor.isOnline():
        print("Power Sensor " + psensor.get_hardwareId() + " is not connected (check identification and USB cable)")
        return None

    return psensor


def clearPowerMeterCache(power_sensor):
    # print("Cleaning powermeter memory ...\n")
    power_sensor.get_dataLogger().forgetAllDataStreams()


def startDataRecording(power_sensor):
    # print("RECORDING MEAUSURES ...\n")
    if not power_sensor.isOnline():
        power_sensor = findPowerSensor("YWATTMK1-1F6860.power")
    power_sensor.startDataLogger()
    data_logger = power_sensor.get_dataLogger()
    while data_logger.get_recording() != 1:
        pass


def stopDataRecording(power_sensor):
    # print("Stop RECORDING MEAUSURES ...\n")
    if not power_sensor.isOnline():
        power_sensor = findPowerSensor("YWATTMK1-1F6860.power")
    power_sensor.stopDataLogger()
    data_logger = power_sensor.get_dataLogger()
    while data_logger.get_recording() != 0:
        pass



def getAveragePower(psensor, startTime, endTime, plStartTime=-1, plEndTime=-1):

    start_date_time = datetime.strptime(startTime, '%Y-%m-%d %H:%M:%S:%f')
    end_date_time = datetime.strptime(endTime, '%Y-%m-%d %H:%M:%S:%f')
    if plStartTime == -1:
        start_timestamp = time.mktime(start_date_time.timetuple())
        end_timestamp = time.mktime(end_date_time.timetuple())
    else:
        start_date_time += datetime.timedelta(seconds=plStartTime)
        start_timestamp = time.mktime(start_date_time.timetuple())
        end_date_time += datetime.timedelta(seconds=plEndTime)
        end_timestamp = time.mktime(end_date_time.timetuple())

    dataset = psensor.get_recordedData(start_timestamp, end_timestamp)

    # print("loading summary... ")
    dataset.loadMore()
    summary = dataset.get_summary()
    avg_power = summary.get_averageValue()
    print("avg_power : ", avg_power)
    if avg_power < 0:
        start_date_time += timedelta(seconds=1)
        start_timestamp = time.mktime(start_date_time.timetuple())
        end_date_time += timedelta(seconds=1)
        end_timestamp = time.mktime(end_date_time.timetuple())
        dataset = psensor.get_recordedData(start_timestamp, end_timestamp)
        dataset.loadMore()
        summary = dataset.get_summary()
        avg_power = summary.get_averageValue()
        print("avg_power : ", avg_power)

    exec_time = end_date_time - start_date_time
    exec_time_in_seconds = exec_time.total_seconds()
    exec_time_in_seconds = exec_time_in_seconds if exec_time_in_seconds > 0 else 1.0
    avg_energy = avg_power * exec_time_in_seconds

    print("Time(s): ", exec_time_in_seconds, " - AVG Power(w): ", avg_power, " - Energy(J): ", avg_energy)
    return (avg_power, exec_time_in_seconds, avg_energy)


def get_query_exec_energy(query, force_order):
    conn, cursor = connect_bdd("imdbload")

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
    time.sleep(2)
    print("4 - is recording: ", psensor.get_dataLogger().get_recording())

    # execute query
    cursor.callproc('getQueryExecutionInfo', (query,))

    endExecTime = datetime.now().strftime("%Y-%m-%d %H:%M:%S:%f")

    result = cursor.fetchone()

    result = result[0].split(";")
    (startTime, executionPlan, endTime) = (result[0].replace(".", ":"), result[1], endExecTime)

    # Regular expressions patterns
    cost_pattern = r"cost=(\d+\.\d+)"
    time_pattern = r"actual time=(\d+\.\d+)\.\.(\d+\.\d+)"

    # Extract cost value
    cost_match = re.search(cost_pattern, executionPlan)
    if cost_match:
        estimated_query_cost = float(cost_match.group(1))
        print("Cost:", estimated_query_cost)
    else:
        print("Cost value not found")

    # Extract actual time value
    time_match = re.search(time_pattern, executionPlan)
    if time_match:
        actual_query_time = float(time_match.group(1))
        print("Actual Time :", actual_query_time)
    else:
        print("Actual Time value not found")

    time.sleep(2)
    stopDataRecording(psensor)

    (power, exec_time, energy) = getAveragePower(psensor, startTime, endTime)


    return energy , actual_query_time ,estimated_query_cost

def get_query_plan_json(query, force_order):
    conn, cursor = connect_bdd("imdbload")

    # Prepare query
    join_collapse_limit = "SET join_collapse_limit ="
    join_collapse_limit += "1" if force_order else "8"


    query = join_collapse_limit + "; EXPLAIN (COSTS, FORMAT JSON, ANALYSE) " + query + ";"
    cursor.execute(query)
    rows = cursor.fetchall()
    real_plan_json = rows[0][0][0]

    print(real_plan_json)

    return real_plan_json




def connect_bdd(name):
    conn = psycopg2.connect(host="localhost",
                            user="postgres", password="postgres",
                            database=name)
    cursor = conn.cursor()
    return [conn, cursor]


def disconnect_bdd(conn):
    conn.close()

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
