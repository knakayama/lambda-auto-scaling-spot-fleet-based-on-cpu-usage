import os
import json
import boto3
import pprint
import datetime

from urllib2 import Request, urlopen, URLError, HTTPError

pp = pprint.PrettyPrinter()


class SpotFleet(object):
    def __init__(self, ec2_client, cw_client):
        self.ec2_client = ec2_client
        self.cw_client = cw_client
        self.spot_fleet_request_id = os.environ['SpotFleetRequestId']

    def describe_spot_fleet_target_capacity(self):
        resp = self.ec2_client.describe_spot_fleet_requests(
                DryRun=False,
                SpotFleetRequestIds=[self.spot_fleet_request_id]
                )
        return resp['SpotFleetRequestConfigs'][0]['SpotFleetRequestConfig']['TargetCapacity']

    def modify_spot_fleet_target_capacity(self, target_capacity):
        self.ec2_client.modify_spot_fleet_request(
                SpotFleetRequestId=self.spot_fleet_request_id,
                TargetCapacity=target_capacity
                )

    def get_spot_fleet_cpu_usage_metric_statistic(self):
        resp = self.cw_client.get_metric_statistics(
                Namespace='AWS/EC2Spot',
                MetricName='CPUUtilization',
                Dimensions=[
                    {
                        'Name': 'FleetRequestId',
                        'Value': self.spot_fleet_request_id
                    }
                ],
                StartTime=datetime.datetime.now() - datetime.timedelta(minutes=30),
                EndTime=datetime.datetime.now(),
                Period=300,
                Statistics=['Average'])
        avgs = [i['Average'] for i in resp['Datapoints']]

        return sum(avgs) / len(avgs)


def notify2slack(message):
    slack_hook_url = os.environ['SlackHookUrl']
    slack_channel = os.environ['SlackChannel']

    slack_message = {
        'channel': slack_channel,
        'text': "%s" % (message)
    }

    req = Request(slack_hook_url, json.dumps(slack_message))
    try:
        response = urlopen(req)
        response.read()
        pp.pprint("Message posted to {}".format(slack_message['channel']))
    except HTTPError as e:
        pp.pprint("Request failed: {} {}".format(e.code, e.reason))
    except URLError as e:
        pp.pprint("Server connection failed: {}".format(e.reason))


def handle(event, context):
    spot_fleet = SpotFleet(boto3.client('ec2'), boto3.client('cloudwatch'))
    max_threshold = os.environ['MaxThreshold']
    min_threshold = os.environ['MinThreshold']
    max_capacity = os.environ['MaxCapacity']
    min_capacity = os.environ['MinCapacity']

    try:
        current_target_capacity = spot_fleet.describe_spot_fleet_target_capacity()
        cpu_usage = spot_fleet.get_spot_fleet_cpu_usage_metric_statistic()
    except Exception as e:
        pp.pprint(e)
        notify2slack(e)
        return

    if current_target_capacity > max_capacity:
        target_capacity = max_capacity
    elif current_target_capacity < min_capacity:
        target_capacity = min_capacity
    else:
        if cpu_usage >= max_threshold:
            target_capacity = current_target_capacity + 1
        elif cpu_usage <= min_threshold:
            target_capacity = current_target_capacity - 1
        else:
            return

    if current_target_capacity == int(target_capacity):
        return

    try:
        spot_fleet.modify_spot_fleet_target_capacity(int(target_capacity))
    except Exception as e:
        pp.pprint(e)
        notify2slack(e)
        return

    message = "Change capacity: {} to {}".format(
            current_target_capacity, target_capacity)
    message += "\nCPUUtilization: {}".format(cpu_usage)
    pp.pprint(message)
    notify2slack(message)
