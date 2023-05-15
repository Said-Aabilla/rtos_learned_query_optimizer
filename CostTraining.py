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
from PGUtils import pgrunner
from energy.energy_functions import *
from energy.solutin_latency_and_energy import get_query_latency
from query_house_api.query import create_query, update_query_join_order
from sqlSample import sqlInfo
import numpy as np
from itertools import count
from math import log
import random
import time
from DQN import DQN, ENV
from TreeLSTM import SPINN
from JOBParser import DB
import copy
import torch
from torch.nn import init
from ImportantConfig import Config

config = Config()

device = torch.device("cuda" if torch.cuda.is_available() and config.usegpu == 1 else "cpu")

with open(config.schemaFile, "r") as f:
    createSchema = "".join(f.readlines())

db_info = DB(createSchema)

featureSize = 128

policy_net = SPINN(n_classes=1, size=featureSize, n_words=100, mask_size=1640, device=device).to(device)
target_net = SPINN(n_classes=1, size=featureSize, n_words=100, mask_size=1640, device=device).to(device)

for name, param in policy_net.named_parameters():
    print(name, param.shape)
    if len(param.shape) == 2:
        init.xavier_normal(param)
    else:
        init.uniform(param)

target_net.load_state_dict(policy_net.state_dict())
target_net.eval()

DQN = DQN(policy_net, target_net, db_info, pgrunner, device)


def k_fold(input_list, k, ix=0):
    li = len(input_list)
    kl = (li - 1) // k + 1
    train = []
    validate = []
    for idx in range(li):

        if idx % k == ix:
            validate.append(input_list[idx])
        else:
            train.append(input_list[idx])
    return train, validate


def QueryLoader(QueryDir):
    def file_name(file_dir):
        import os
        L = []
        print(file_dir)
        for root, dirs, files in os.walk(file_dir):
            for file in files:
                if os.path.splitext(file)[1] == '.sql':
                    L.append(os.path.join(root, file))
        return L

    files = file_name(QueryDir)
    sql_list = []
    for filename in files:
        with open(filename, "r") as f:
            data = f.readlines()
            one_sql = "".join(data)
            sql_list.append(sqlInfo(pgrunner, one_sql, filename))
    return sql_list


def resample_sql(sql_list):
    rewards = []
    reward_sum = 0
    rewardsP = []
    mes = 0
    DP_cost = 0.0
    my_cost = 0.0
    s_rewards = 0
    lr = len(sql_list)
    for sql in sql_list:
        #         sql = val_list[i_episode%len(train_list)]
        pg_cost = sql.getDPlantecy()
        DP_cost += pg_cost
        #         continue
        env = ENV(sql, db_info, pgrunner, device)

        for t in count():
            action_list, chosen_action, all_action = DQN.select_action(env, need_random=False)

            left = chosen_action[0]
            right = chosen_action[1]
            env.takeAction(left, right)

            reward, done, rtos_cost, new_query = env.reward_new()
            if done:
                mrc = max(reward - 1, 0)
                rewardsP.append(reward)
                mes += log(reward)
                s_rewards += reward
                my_cost += reward * pg_cost
                rewards.append((mrc, sql))
                reward_sum += mrc
                break
    import random
    print(rewardsP)
    res_sql = []
    print(mes / len(sql_list))
    for idx in range(len(sql_list)):
        rd = random.random() * reward_sum
        for ts in range(len(sql_list)):
            rd -= rewards[ts][0]
            if rd < 0:
                res_sql.append(rewards[ts][1])
                break
    from math import e
    print("MRC", s_rewards / lr, "GMRL", e ** (mes / lr), "SMRC", my_cost / DP_cost)
    return res_sql + sql_list


def train(trainSet, validateSet):
    baselines = []
    saved_query_ids = []
    for sqlt in trainSet:
        # break
        print("I am here with sqlt : ", sqlt.filename)
        env = ENV(sqlt, db_info, pgrunner, device)
        pg_cost = sqlt.getDPlantecy()
        sqlt.alias_cnt = len(env.sel.from_table_list)
        previous_state_list = []
        action_this_epi = []
        if (len(env.sel.from_table_list) < 3) or not env.sel.baseline.left_deep:
            baselines.append(-1)
            continue
        for t in count():
            print("start taking actions")
            action_list, chosen_action, all_action = DQN.select_action(env, need_random=True)
            value_now = 0
            next_value = torch.min(action_list).detach()
            env_now = copy.deepcopy(env)
            chosen_action = env.sel.baseline.result_order[t]

            left = chosen_action[0]
            right = chosen_action[1]
            env.takeAction(left, right)
            action_this_epi.append((left, right))

            reward, done, rtos_cost, new_query = env.reward_new()
            previous_state_list.append((value_now, next_value.view(-1, 1), env_now))
            if done:
                print("done taking actionsgot reward")
                sqlt.updateBestOrder(reward, action_this_epi)

                print("best order:", sqlt.getBestOrder())
                baselines.append(reward)
                reward = log(1 + reward)
                if reward > config.maxR:
                    reward = config.maxR
                    break
                next_value = 0
                # break
            reward = torch.tensor([reward], device=device, dtype=torch.float32).view(-1, 1)
            expected_state_action_values = (next_value) + reward.detach()
            final_state_value = (next_value) + reward.detach()
            if done:
                cnt = 0

                DQN.Memory.push(env, expected_state_action_values, final_state_value)
                for pair_s_v in previous_state_list[:0:-1]:
                    DQN.Memory.push(pair_s_v[2], expected_state_action_values, final_state_value)
            if done:
                print("calling optimzer")
                loss = DQN.optimize_model()
                print("  optimzer done")
                break
    trainSet_temp = trainSet
    losses = []
    startTime = time.time()
    print_every = 20
    TARGET_UPDATE = 3
    save_every = 200
    for i_episode in range(0, 10000):
        print("Reched episode: ", i_episode)
        if i_episode % 200 == 100:
            trainSet = resample_sql(trainSet_temp)
        #     sql = random.sample(train_list_back,1)[0][0]
        sqlt = random.sample(trainSet[0:], 1)[0]
        print("I am here with sqlt : ", sqlt.filename)

        # save query to query_house
        query_id = create_query(sqlt.sql)
        print("query_id: ", query_id)

        saved_query_ids.append(query_id)
        print("saved_query_ids: ", saved_query_ids)

        env = ENV(sqlt, db_info, pgrunner, device)

        previous_state_list = []
        action_this_epi = []
        nr = True
        nr = random.random() > 0.3 or sqlt.getBestOrder() == None
        acBest = (not nr) and random.random() > 0.7
        for t in count():
            # beginTime = time.time();
            action_list, chosen_action, all_action = DQN.select_action(env, need_random=nr)
            value_now = env.selectValue(policy_net)
            next_value = torch.min(action_list).detach()
            # e1Time = time.time()
            env_now = copy.deepcopy(env)
            # endTime = time.time()
            # print("make",endTime-startTime,endTime-e1Time)
            if acBest:
                chosen_action = sqlt.getBestOrder()[t]
            left = chosen_action[0]
            right = chosen_action[1]
            env.takeAction(left, right)
            action_this_epi.append((left, right))

            reward, done, rtos_cost, new_query = env.reward_new()
            previous_state_list.append((value_now, next_value.view(-1, 1), env_now))
            if done:
                sqlt.updateBestOrder(reward, action_this_epi)
                rtos_json_plan = get_query_plan_json(new_query, True)
                pg_json_plan =  get_query_plan_json(sqlt.sql, False)
                rtos_energy, rtos_exec_time, rtos_cost = get_query_exec_energy(new_query, True)
                pg_energy , pg_exec_time, pg_cost= get_query_exec_energy(sqlt.sql, False)

                filename = sqlt.filename.replace("workload/api_test_queries/", "")
                print(filename)
                update_query_join_order(filename, i_episode,query_id, action_this_epi, rtos_exec_time, pg_exec_time,rtos_energy, pg_energy, rtos_cost, pg_cost, rtos_json_plan, pg_json_plan)
                reward = log(reward + 1)
                if reward > config.maxR:
                    reward = config.maxR
                next_value = 0
            reward = torch.tensor([reward], device=device, dtype=torch.float32).view(-1, 1)
            expected_state_action_values = (next_value) + reward.detach()
            final_state_value = (next_value) + reward.detach()
            if done:
                cnt = 0

                DQN.Memory.push(env, expected_state_action_values, final_state_value)
                for pair_s_v in previous_state_list[:0:-1]:
                    DQN.Memory.push(pair_s_v[2], expected_state_action_values, final_state_value)
                loss = 0
            if done:
                # break
                loss = DQN.optimize_model()
                losses.append(loss)
                if ((i_episode + 1) % print_every == 0):
                    print(np.mean(losses))
                    print("######################Epoch", i_episode // print_every, pg_cost)
                    val_value = DQN.validate(validateSet)
                    print("time", time.time() - startTime)
                    print("~~~~~~~~~~~~~~")
                break
        if i_episode % TARGET_UPDATE == 0:
            target_net.load_state_dict(policy_net.state_dict())
        # if i_episode % save_every == 0:
        # torch.save(policy_net.cpu().state_dict(), 'CostTraining' + str(i_episode) + '.pth')
    torch.save(policy_net.cpu().state_dict(), 'saved_model/test.pth')
    # policy_net = policy_net.cuda()


if __name__ == '__main__':
    sytheticQueries = QueryLoader(QueryDir=config.sytheticDir)
    print(len(sytheticQueries))
    JOBQueries = QueryLoader(QueryDir=config.JOBDir)
    print(len(JOBQueries))
    Q4, Q1 = k_fold(JOBQueries, 10, 1)
    print(len(Q4), len(Q1))
    # print(Q4,Q1)

    # # ENERGY CODE START
    # psensor = findPowerSensor("YWATTMK1-1F6860.power")
    # stopDataRecording(psensor)
    # clearPowerMeterCache(psensor)
    # tm = time.time()
    # datalog = psensor.get_dataLogger()
    # datalog.set_timeUTC(time.time())
    # startDataRecording(psensor)  # Power Meter starts recording power per second
    # time.sleep(2.0)
    # print("4 - is recording: ", psensor.get_dataLogger().get_recording())
    # startTime = datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S:%f')
    # # ENERGY CODE END

    train(Q4 + sytheticQueries, Q1)

    # # ENERGY CODE START
    # endTime = datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S:%f')
    # # print("4-4 - is recording: ", psensor.get_dataLogger().get_recording())
    # print("startTime: ", startTime, " - endTime: ", endTime)
    # # YAPI.Sleep(2000)
    # time.sleep(2.0)
    # print("stop recording : ", datetime.now())
    # stopDataRecording(psensor)
    # print("7 - is recording: ", psensor.get_dataLogger().get_recording())
    #
    # (power, exec_time, energy) = getAveragePower(psensor, startTime, endTime)
    # # ENERGY CODE END
