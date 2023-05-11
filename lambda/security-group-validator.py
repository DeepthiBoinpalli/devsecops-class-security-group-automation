import json
import boto3
import logging
import urllib3
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    
    tagKey = ''
    tagValue = ''
    tagFlag = 0
    print(event)
    
    eventName = str(event['detail']['eventName'])
    awsRegion = str(event['detail']['awsRegion'])
    userName = str(event['detail']['userIdentity']['userName'])
    sgGroupId = str(event['detail']['requestParameters']['groupId'])
    ingressIp = str(event['detail']['requestParameters']['ipPermissions']['items'][0]['ipRanges']['items'][0]['cidrIp'])
    fromPort = str(event['detail']['requestParameters']['ipPermissions']['items'][0]['fromPort'])
    toPort = str(event['detail']['requestParameters']['ipPermissions']['items'][0]['toPort'])

    print(sgGroupId)
    print(event)
    
    client = boto3.client('ec2')
    response = client.describe_security_groups(GroupIds = [sgGroupId])
    
    for item in response['SecurityGroups'][0]:
        if(item == 'Tags'):
            tagFlag = 1
    
    if(tagFlag == 1):
        tagInfo = response['SecurityGroups'][0]['Tags']
        for i in tagInfo:
            if(i['Key'] == 'approved_by' and i['Value'] == 'cso-group'):
                tagKey = i['Key']
                tagValue = i['Value']
                
    
    print(tagKey)
    print(tagValue)
    print(tagFlag)
    
    if(eventName == 'AuthorizeSecurityGroupIngress' and ingressIp == '0.0.0.0/0'):
        if(tagKey == 'approved_by' and tagValue == 'cso-group'):
            print("Security Group is good")
        else:
            message1 = str(" **** SECURITY GROUP COMPLIANCE ALERT (development) ***** || " + str(awsRegion))
            message2 = str(" || User Name: " + str(userName) + " || Security group: " + str(sgGroupId) + " || Port:" + str(fromPort) + " || Ingress CIDR:" + str(ingressIp) + " ||" )
            message = message1+message2
            print("Security Group is not good")
            send_notification(message)
            #update_ingress_ip(sgGroupId,fromPort,toPort)

    #Update output for debugging purposes
    return {
        "StatusCode": 200
    }

def update_ingress_ip(sgId,fromPort,toPort):
    print('update_ingress_ip SG: ' + sgId + 'From Port: ' + fromPort + 'To Port: ' + toPort)
    ec2client = boto3.client('ec2')
    
    ec2client.revoke_security_group_ingress(
        GroupId=sgId,
        IpPermissions=[
            {'IpProtocol': 'tcp',
             'FromPort': int(fromPort),
             'ToPort': int(toPort),
             'IpRanges': [{'CidrIp': '0.0.0.0/0'}]}
        ])

    data = ec2client.authorize_security_group_ingress(
        GroupId=sgId,
        IpPermissions=[
            {'IpProtocol': 'tcp',
             'FromPort': int(fromPort),
             'ToPort': int(toPort),
             'IpRanges': [{'CidrIp': '175.46.237.10/32'}]}
        ])

def send_notification(message):
    client = boto3.client('sns')
    response = client.publish(
        TopicArn=os.environ['sns_topic'],
        Message=message,
        Subject=os.environ['sns_subject'],
    )
    return 
