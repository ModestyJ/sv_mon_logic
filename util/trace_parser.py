#!/usr/bin/env python
import json
import argparse
from  tqdm import tqdm
def main(args):

    #################################
    # Parse profile json
    # Open trace.json
    json_file = open(args.input,encoding = 'utf-8')
    trace_events = json.load(json_file)

    # identify unique event(name+pid+tid)
    event_id = []

    # save unique opt data
    dic_unique = {}
    keys = ['name', 'ph', 'ts', 'dur', 'tid', 'pid']
    trace_events = trace_events["traceEvents"]
    print('Total number of input trace_events:', len(trace_events))

    for i in tqdm(range(len(trace_events))):
        if 'dur' in trace_events[i]:
            if trace_events[i]['name'] + str(trace_events[i]['pid']) + str(trace_events[i]['tid']) not in event_id:
                
                event_id.append(trace_events[i]['name'] 
                    + str(trace_events[i]['pid']) + str(trace_events[i]['tid']))
                dic_unique[trace_events[i]['name'] 
                    + str(trace_events[i]['pid']) + str(trace_events[i]['tid'])] = trace_events[i]
                dic_unique[trace_events[i]['name'] 
                    + str(trace_events[i]['pid']) + str(trace_events[i]['tid'])]['call_num'] = 1
            else:
                dic_unique[trace_events[i]['name'] + str(trace_events[i]['pid']) 
                    + str(trace_events[i]['tid'])]['call_num'] += 1
                dic_unique[trace_events[i]['name'] + str(trace_events[i]['pid']) +
                    str(trace_events[i]['tid'])]['dur'] += trace_events[i]['dur']

    keys.append('call_num') #the call_num is the numbers calls of a function
    event_list=[dic_unique[x] for x in event_id]

    # close trace.json
    json_file.close()

    #################################
    # Get data to calculate utilization
    # Open trace.json
    json_file = open(args.util,encoding = 'utf-8')
    util_data = json.load(json_file)
    pf = util_data['parallelism_factor']
    freq = util_data['clock']
    mac_list = util_data['mac']

    max_gops = freq*pf*pf*2
    print("Maximum GOPS for ", pf,"x",pf, " MACs @", freq, "GHz = ", max_gops)

    total_dur = 0.0;
    total_mac = 0;
    print ("{:<10} {:<15} {:<15} {:<10}".format('Layer','Target Opts','Runtime(ns)','Utilization(%)'))

    list_dur = []
    for layer_num in range(len(mac_list)):
        layer_name = "layer"+str(layer_num)
        it = (item for item in event_list if layer_name in item['name'])
        search_result = next(it, False)
        if(search_result):
            print ("{:<10} {:<15} {:<15} {:0.2f}".format(search_result['name'], mac_list[layer_num], search_result['dur'], (mac_list[layer_num]/search_result['dur'])/max_gops*100))
            total_mac += mac_list[layer_num]
            total_dur += search_result['dur']
            list_dur.append(search_result['dur'])
        else:
            print('There is no layer in the simulation result: ',layer_name,'\n')

    print("{:<10} {:<15} {:<15} {:0.2f}".format("Overall", total_mac, int(total_dur), total_mac/total_dur/max_gops*100))
    print("Overall utilization: ", "{0:0.2f}".format((total_mac/total_dur)/max_gops*100),"%")

    # close trace.json
    json_file.close()

    if(args.debug):
        #################################
        # Search profile data
        # search for the name and print runtime
        while(True):
            target = str(input('\nPlease type the name you want to search for or \'exit\'>'))
            if(target=='exit'): break

            it = (item for item in event_list if target in item['name'])
            search_result = next(it, False)
            if(search_result):
                print(search_result['name'], ": total run time:",search_result['dur'],"us,", "average:",search_result['dur']/search_result['call_num'],"us\n")
            else:
                print('There is no item include ',target,'\n')

    if(args.debugutil):
        #################################
        # Calculate utilization for target layers
        targets=[]
        targets_dur = 0.0
        targets_mac = 0
        while(True):
            target = str(input('\nPlease type the number of layer or \'util\' or \'exit\'\n>'))
            if(target=='exit'): break
            elif(target=='util'):
                print("\n<Statistics for layer ",end='')
                for layer_num in targets:
                    print(layer_num,end=',')
                    targets_dur += list_dur[layer_num]
                    targets_mac += mac_list[layer_num]
                print(">")
                print ("{:<10} {:<15} {:<15} {:<10}".format('Layer','Target Opts','Runtime(ratio)','Utilization(%)'))
                print("{:<10} {:<15} {:d}({:.2%})\t {:0.2f}".format("Targets", targets_mac, int(targets_dur),targets_dur/total_dur, targets_mac/targets_dur/max_gops*100))
                targets=[]
                targets_dur = 0.0
                targets_mac = 0
            else:
                targets.append(int(target))

if __name__=='__main__':
    parser = argparse.ArgumentParser(description='help')
    parser.add_argument('--input', '-i', type=str, default="profile.json", help='simulation profile result(json file)')
    parser.add_argument('--util', '-u', type=str, default="util.json", help='data to calculate utilization for each layer(json file)')
    parser.add_argument('--debug', '-d', action='store_true', default=False, help='manual debug mode')
    parser.add_argument('--debugutil', '-du', action='store_true', default=False, help='manual debug mode')
    args = parser.parse_args()
    main(args)
