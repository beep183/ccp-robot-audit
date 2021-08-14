*** Settings ***
Library    ccplib.CCPLib    ${CONFIG_FILE}    ${CONFIG_DIR}
Suite Setup    Open Config File

*** Variables ***
${CONFIG_DIR}    configs
${CONFIG_FILE}    DEN-EDGE01.ios.conf

*** Keywords ***
Open Config File
    [Arguments]    
    [Documentation]    
    ${CCP_OBJ} =    Parse Config File
    Set Suite Variable    ${CCP_OBJ}

    [Return]    ${None}

Test Config Section OSPF
   [Arguments]    ${DEVICE}    ${REQUIRED}
   [Documentation]    Verify OSPF router settings
    ...    For each ``required_line`` in pytest.mark.parametrize() above, run a 
    ...    seperate pytest to ensure the line is configured under the appropriate IGP.

   ${IGP_LINE} =    Set Variable    ^router\\sospf

   Comment    Find any matching IGP_LINE, in this case 'router ospf'
   ${igp_objs} =    Set Variable     ${DEVICE.find_objects('${IGP_LINE}')}

   Length Should Be    ${igp_objs}    1    Require exactly one IGP

   ${igp_obj} =    Set Variable     ${igp_objs[0]}
   ${test_val} =    Set Variable    ${igp_obj.re_match_iter_typed('${REQUIRED}', group=0, result_type=str, default="__FAILED__")}
   Should Not Be Equal    ${test_val}    __FAILED__     Could not find required line '${REQUIRED}'\n

   [Return]    ${None}

Test Config Section OSPF Negative
    [Arguments]    ${DEVICE}    ${REJECTED}
    [Documentation]    Verify OSPF router is *not* configured with these lines
    ...    For each ``rejected_line`` in pytest.mark.parametrize() above, run a 
    ...    seperate pytest to ensure the line is *not* configured under the 
    ...    appropriate IGP.

    ${IGP_LINE} =    Set Variable    ^router\\sospf

    Comment    Find any matching IGP_LINE, in this case 'router ospf'
    ${igp_objs} =    Set Variable     ${DEVICE.find_objects('${IGP_LINE}')}
    Length Should Be    ${igp_objs}    1    Require exactly one IGP

    ${igp_obj} =    Set Variable     ${igp_objs[0]}
    ${test_val} =    Set Variable    ${igp_obj.re_match_iter_typed('${REJECTED}', group=0, result_type=str, default="__PASSED__")}
    Should Be Equal    ${test_val}    __PASSED__    Found rejected line '${REJECTED}'\n

    [Return]    ${None}

Test Uplinks
    [Arguments]    ${DEVICE}    ${INTERFACE}
    [Documentation]    check uplinks for sanity

    Comment    Find all interfaces with UPLINK in the description
    ...        skip all interfaces that *don't* use UPLINK in the description
    ${uplink_objs} =    Set Variable    ${DEVICE.find_objects_w_child(r'^' + '${INTERFACE}' + r'\s*$', r'^\s+description\s.*?UPLINK')}
    ${uplink_objs_len} =    Get Length    ${uplink_objs}
    Return From Keyword If    ${uplink_objs_len} < 1    ${INTERFACE} not an uplink
    Run Keyword And Continue On Failure    Should Not Be True    ${uplink_objs_len} > 1    ${INTERFACE} more than one uplink matches

    ${uplink} =    Set Variable    ${uplink_objs[0]}
    ${uplink_port} =    Set Variable    ${uplink.re_match_typed(r'interface\s+\S+.*?(\d+\/\d+.*)\s*$')}

    Comment    This could be lag
    Run Keyword Unless   '${uplink.re_search('[Pp]ort-channel')}' == ''
    ...    ${uplink} =    Set Variable    {DEVICE.find_objects('^interface \S+?thernet\s*${uplink_port}')[0]}

    Run Keyword And Continue On Failure    Should Not Be Empty    ${uplink.re_search_children("ipv6 enable")}    IPv6 is not enabled on ${INTERFACE}\n
    Run Keyword And Continue On Failure    Should Not Be Empty    ${uplink.re_search_children("ipv6 address ([0-9a-f:]+:[12]/64)")}    IPv6 address is not configured on ${INTERFACE}\n

*** Test Cases ***
OSPF Configuration
    Test Config Section OSPF    ${CCP_OBJ}    maximum-paths 8
    Test Config Section OSPF    ${CCP_OBJ}    redistribute static
    Test Config Section OSPF Negative    ${CCP_OBJ}    redistribute connected

Interface Uplink Configuration
    ${interfaces} =    Set Variable    ${CCP_OBJ.find_lines(r'^interface GigabitEthernet', exactmatch=False)}
    ${interfaces_length} =    Get Length    ${interfaces}
    Skip If    ${interfaces_length} < 1    No matching interfaces found\n
    FOR    ${interface}    IN    @{interfaces}
        Test Uplinks    ${CCP_OBJ}    ${interface}
    END
