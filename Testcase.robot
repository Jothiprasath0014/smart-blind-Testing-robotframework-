*** Settings ***
Library  MicrobitGPIO
Library  MQTTLibrary
Library  String

Suite Setup  Connect to Devices

Suite Teardown  Disconnect from Devices

*** Variables ***
${MQTT Broker}  192.168.000.00
${Microbit Port}  /dev/ttyACM0
${Baud Rate}  115200
${Analog Pin}  1
${Topic}  Test 

*** Test Cases ***
Test Normal condition
    Set Analog Period
    Write Analog Value  410
    MQTTLibrary.Subscribe  ${Topic}  1
    @{messages}=  Listen  ${Topic}  timeout=10  limit=0
    Validate Normal Distance  ${messages}

Test Alert condition
    Set Analog Period
    Write Analog Value  20
    MQTTLibrary.Subscribe  ${Topic}  1
    @{messages}=  Listen  ${Topic}  timeout=10  limit=0
    Validate Alert Distance  ${messages}

*** Keywords ***
Connect to Devices
    Connect to MQTT Broker
    Connect to Microbit

Connect to MQTT Broker
    MQTTLibrary.Connect  ${MQTT Broker}

Connect to Microbit
    MicrobitGPIO.Connect  ${Microbit Port}  ${Baud Rate}

Set Analog Period
    MicrobitGPIO.Set Analog Period  ${Analog Pin}  10000

Write Analog Value
    [Arguments]  ${value}
    MicrobitGPIO.Write Analog  ${Analog Pin}  ${value}

Validate Normal Distance
    [Arguments]  ${messages}
    FOR  ${message}  IN  @{messages}
        ${distance} =  Convert To Number  ${message}
        ${result} =  Evaluate  ${distance} > 100
        Run Keyword If  not ${result}  Fail  Distance should be greater than 10: ${message}
    END

Validate Alert Distance
    [Arguments]  ${messages}
    FOR  ${message}  IN  @{messages}
        ${distance} =  Convert To Number  ${message}
        ${result} =  Evaluate  ${distance} < 10
        Run Keyword If  not ${result}  Fail  Distance should be less than 10: ${message}
    END

Disconnect from Devices
    MicrobitGPIO.Disconnect
    MQTTLibrary.Disconnect
 
