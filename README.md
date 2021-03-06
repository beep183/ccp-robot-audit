# ccp-robot-audit
Audit Network Configuration Files with CiscoConfParse and Robot Framework

Based on the ciscoconfparse-audit code written by David Michael Pennington.

This repository contains an adaption of the [ciscoconfparse](https://github.com/mpenning/ciscoconfparse) pytest [testcases](https://github.com/mpenning/ciscoconfparse-audit). Without a doubt pytest is amazing and does the job, however if you're using Robot Framework you you expect a _user friendly_ to go with it. Robot Framework supports keyword and data driven testcases, however it comes nowhere near the efficiency of pytest. If you are using Robot Framework this can be a good starting point to use the great features of CiscoConfParse in your test cases.

## Usage
The use of Robot Framework is easy. In the example you can pass the configfile parameter on the command line. You can also edit the robot file and change the default value of the `CONFIG_FILE` variable directly.

Run the test_router.robot test suite.

	robot -v CONFIG_FILE:myrouter.cfg test_router.robot

Run all test suites.

	robot -v CONFIG_FILE:myrouter.cfg *.robot
