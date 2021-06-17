#!/usr/bin/env python3
# -*- coding=utf-8 -*-
import os
import sys

import click
import cromwell_tools
# from cromwell_tools.cromwell_auth import CromwellAuth


BASE_DIR = os.path.dirname(os.path.realpath(__file__))
WDL_ROOT = os.path.join(os.path.dirname(BASE_DIR), 'wdl')


url = 'http://172.30.1.1:8008'


auth = cromwell_tools.cromwell_auth.CromwellAuth.harmonize_credentials(url=url)

response = cromwell_tools.api.submit(
    auth, f'{WDL_ROOT}/main.wdl',
    inputs_files=f'{WDL_ROOT}/../tests/test_main/inputs.json',
    options_file=f'{WDL_ROOT}/../tests/options.json',
    dependencies=[f'{WDL_ROOT}/main.zip'])

print(response.json())
