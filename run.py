# Copyright 2018-2021 Tsinghua DBGroup
#
# Licensed under the Apache License, Version 2.0 (the "License"): you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
import os

from PGUtils import pgrunner
from energy.energy_functions import *
from sqlSample import sqlInfo
import numpy as np
from itertools import count
from math import log
import random
import time
from DQN import DQN,ENV
from TreeLSTM import SPINN
from JOBParser import DB
import copy
import torch
from torch.nn import init
from ImportantConfig import Config

config = Config()

device = torch.device("cuda" if torch.cuda.is_available() and config.usegpu==1 else "cpu")


with open(config.schemaFile, "r") as f:
    createSchema = "".join(f.readlines())

db_info = DB(createSchema)

featureSize = 128

policy_net = SPINN(n_classes = 1, size = featureSize, n_words = 100,mask_size= 40*41,device=device).to(device)
target_net = SPINN(n_classes = 1, size = featureSize, n_words = 100,mask_size= 40*41,device=device).to(device)
policy_net.load_state_dict(torch.load("saved_model/CostTraining.pth"))
target_net.load_state_dict(policy_net.state_dict())
target_net.eval()

DQN = DQN(policy_net,target_net,db_info,pgrunner,device)

if __name__=='__main__':


        # Set the path to the directory containing the files
        directory_path = "JOB-queries"
        elements = ['3b.sql', '1a.sql', '32a.sql', '8a.sql', '7a.sql', '25a.sql', '19a.sql', '22a.sql', '24a.sql', '28a.sql', '29b.sql']

        # Loop over all the files in the directory
        for filename in os.listdir(directory_path) :
            # Check if the file is a file and not a directory
            if os.path.isfile(os.path.join(directory_path, filename)) and filename in elements:

                # Open the file for reading
                with open(os.path.join(directory_path, filename), 'r') as file:
                    # Read the contents of the file
                    query = file.read()
                    sqlSample = sqlInfo(pgrunner, query, filename)

                    env = ENV(sqlSample, db_info, pgrunner, device)
                    print("-------------" + filename + "----------------")
                    # print("pg cost", sqlSample.getDPCost())

                    # ENERGY CODE START
                    psensor = findPowerSensor("YWATTMK1-1F6860.power")
                    stopDataRecording(psensor)
                    clearPowerMeterCache(psensor)
                    tm = time.time()
                    datalog = psensor.get_dataLogger()
                    datalog.set_timeUTC(time.time())
                    startDataRecording(psensor)  # Power Meter starts recording power per second
                    time.sleep(2.0)
                    print("4 - is recording: ", psensor.get_dataLogger().get_recording())
                    startTime = datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S:%f')
                    # ENERGY CODE END


                    try:
                        run_start_time = time.time()
                        for t in count():
                            action_list, chosen_action, all_action = DQN.select_action(env, need_random=False)

                            left = chosen_action[0]
                            right = chosen_action[1]
                            env.takeAction(left, right)

                            reward, done = env.reward_new(filename)
                            if done:
                                run_end_time = time.time()
                                # ENERGY CODE START
                                endTime = datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S:%f')
                                # print("4-4 - is recording: ", psensor.get_dataLogger().get_recording())
                                print("startTime: ", startTime, " - endTime: ", endTime)
                                # YAPI.Sleep(2000)
                                time.sleep(2.0)
                                print("stop recording : ", datetime.now())
                                stopDataRecording(psensor)
                                print("7 - is recording: ", psensor.get_dataLogger().get_recording())

                                (power, exec_time, energy) = getAveragePower(psensor, startTime, endTime)
                                # ENERGY CODE END

                                # Calculate time difference in milliseconds
                                time_diff_ms = (run_end_time - run_start_time) * 1000

                                # Print result in milliseconds
                                print("Time taken: {:.2f} ms".format(time_diff_ms))
                    except Exception:
                        print("continue")


        print("-----------------------------")


    # ###No online update now
    # print("Enter each query in one line")
    # print("---------------------")
    # while (1):
    #     # print(">",end='')
    #     query = input(">")
    #     sqlSample = sqlInfo(pgrunner,query,"input")
    #     # pg_cost = sql.getDPlantecy()
    #     env = ENV(sqlSample,db_info,pgrunner,device,run_mode = True)
    #     print("-----------------------------")
    #     for t in count():
    #             action_list, chosen_action,all_action = DQN.select_action(env,need_random=False)
    #
    #             left = chosen_action[0]
    #             right = chosen_action[1]
    #             env.takeAction(left,right)
    #
    #             reward, done = env.reward_new()
    #             if done:
    #                 for row in reward:
    #                     print(row)
    #                 break
    #     print("-----------------------------")
    #
    #
