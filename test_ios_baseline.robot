*** Settings ***
Library    ccplib.CCPLib    ${CONFIG_FILE}    ${CONFIG_DIR}
Suite Setup    Open Config File

*** Variables ***
${CONFIG_DIR}    ../../configs
${CONFIG_FILE}    DEN-EDGE01.ios.conf

*** Keywords ***
Open Config File
    [Arguments]    
    [Documentation]    
    ${CCP_OBJ} =    Parse Config File
    Set Suite Variable    ${CCP_OBJ}

    [Return]    ${None}

Test Config Section VTY
    [Arguments]    ${DEVICE}    ${REQUIRED}
    [Documentation]    Required vty configs

    ${VTY_REGEX} =    Set Variable    line\\svty\\s(\\d.+)\\s*$

    ${ttys} =    Set Variable     ${DEVICE.find_objects(r'${VTY_REGEX}')}
    ${ttys_length} =    Get Length    ${ttys}
    Should Be True    ${ttys_length} > 0    No vty lines found

    FOR    ${index}    IN RANGE    ${ttys_length}
        ${test_val} =    Set Variable    ${ttys[${index}].re_match_iter_typed('${REQUIRED}', group=0, result_type=str, default="__FAIL__")}
        Run Keyword And Continue On Failure    Should Not Be Equal    ${test_val}    __FAIL__    Could not find required line '${REQUIRED}'\n
    END

    [Return]    ${None}

Test Config Line Exact
    [Arguments]    ${DEVICE}    ${REQUIRED}
    [Documentation]    Required global configurations
    Run Keyword And Continue On Failure    Should Not Be Empty    ${DEVICE.find_lines(r'^'+'${REQUIRED}'+'$', exactmatch=True)}    Could not find required line '${REQUIRED}'\n

    [Return]    ${None}

Test Config Line Exact Negative
    [Arguments]    ${DEVICE}    ${REJECTED}
    [Documentation]    Rejected global configurations
    Run Keyword And Continue On Failure    Should Be Empty    ${DEVICE.find_lines(r'^'+'${REJECTED}'+'$', exactmatch=True)}    Found rejected line '${REJECTED}'\n

    [Return]    ${None}

Test Config Line Partial
    [Arguments]    ${DEVICE}    ${REQUIRED}
    [Documentation]    Required global configurations
    Run Keyword And Continue On Failure    Should Not Be Empty    ${DEVICE.find_lines(r'^'+'${REQUIRED}', exactmatch=False)}    Could not find line containing '${REQUIRED}'\n

    [Return]    ${None}

*** Test Cases ***
Required Global Configuration
    [Documentation]    Required global config lines

    Comment    Exact matches
    Test Config Line Exact    ${CCP_OBJ}    service timestamps debug datetime msec localtime show-timezone
    Test Config Line Exact    ${CCP_OBJ}    service timestamps log datetime msec localtime show-timezone
    Test Config Line Exact    ${CCP_OBJ}    clock timezone MST -7
    Test Config Line Exact    ${CCP_OBJ}    service tcp-keepalives-in
    Test Config Line Exact    ${CCP_OBJ}    service tcp-keepalives-out
    Test Config Line Exact    ${CCP_OBJ}    ip tcp selective-ack
    Test Config Line Exact    ${CCP_OBJ}    ip tcp timestamp
    Test Config Line Exact    ${CCP_OBJ}    ip tcp synwait-time 10
    Test Config Line Exact    ${CCP_OBJ}    ip tcp path-mtu-discovery
    Test Config Line Exact    ${CCP_OBJ}    memory reserve critical 4096

    Comment    Partial matches
    Test Config Line Partial    ${CCP_OBJ}    clock summer-time MDT recurring
    Test Config Line Partial    ${CCP_OBJ}    enable secret
    Test Config Line Partial    ${CCP_OBJ}    hostname

SNMP Configuration
    [Documentation]     Required or rejected SNMP config lines

    Comment    Exact matches
    Test Config Line Exact    ${CCP_OBJ}    ${{ r'snmp-server community {0} [rR][oO] 99'.format(re.escape('g1v3mE$t@t$')) }}
    Test Config Line Exact    ${CCP_OBJ}    ${{ r'snmp-server community {0} [rR][wW] 99'.format(re.escape('SoMeThaNGwIErd')) }}

    Comment    Exact negative matches    
    Test Config Line Exact Negative    ${CCP_OBJ}    snmp-server\\scommunity\\s\\S+\\s+[rR][wW]
    Test Config Line Exact Negative    ${CCP_OBJ}    snmp-server\\scommunity\\s\\S+\\s+[rR][oO]


Logging Configuration
    [Documentation]     Required logging config lines

    Comment    Exact matches
    Test Config Line Exact    logging 172.16.15.2
    Test Config Line Exact    logging buffered 65535 debugging


Services Configuration
    [Documentation]     Required or rejected services config lines

    Comment    Exact matches
    Test Config Line Exact    ${CCP_OBJ}    no service pad
    Test Config Line Exact    ${CCP_OBJ}    no ip domain-lookup
    Test Config Line Exact    ${CCP_OBJ}    ip ospf name-lookup
    Test Config Line Exact    ${CCP_OBJ}    no ip source-route
    Test Config Line Exact    ${CCP_OBJ}    no ip gratuitous-arps

    Comment    Exact negative matches
    Test Config Line Exact Negative    ${CCP_OBJ}    service internal
    Test Config Line Exact Negative    ${CCP_OBJ}    enable password
    Test Config Line Exact Negative    ${CCP_OBJ}    ip http server
    Test Config Line Exact Negative    ${CCP_OBJ}    ip http secure-server
    Test Config Line Exact Negative    ${CCP_OBJ}    ntp master

VTY Line Configuration
    [Documentation]     Required VTY config lines

    Comment    Iterate VTY section lines
    Test Config Section VTY    ${CCP_OBJ}    ${SPACE}logging synchronous
    Test Config Section VTY    ${CCP_OBJ}    ${SPACE}exec-timeout 5 0
    Test Config Section VTY    ${CCP_OBJ}    ${SPACE}transport preferred none