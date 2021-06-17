#!/usr/bin/env python3
# -*- coding=utf-8 -*-
import os
import sys
import json
from configparser import ConfigParser

import click
import requests
import cromwell_tools
from cromwell_tools.cromwell_auth import CromwellAuth
from pygments import highlight, lexers, formatters


BASE_DIR = os.path.dirname(os.path.realpath(__file__))
WDL_ROOT = os.path.join(os.path.dirname(BASE_DIR), 'wdl')

DEFAULT_CONFIG = os.path.join(os.path.expanduser('~'), '.cromwell_server.ini')


def check_url(configfile=DEFAULT_CONFIG, section='cromwell_server'):
    conf = ConfigParser()
    need_update = False

    msg = click.style('Please input your url of cromwell server[http://HOST:PORT]', fg='green', bold=True)

    if os.path.isfile(configfile):
        conf.read(configfile)
        url = conf.get(section, 'url')
    else:
        url = click.prompt(msg)
        need_update = True

    while True:
        try:
            auth = CromwellAuth.harmonize_credentials(url=url, username='no', password='no')
            cromwell_tools.api.health(auth)
            break
        except Exception as e:
            click.secho(f'auth failed as: {e}', fg='red')
            url = click.prompt(msg)
            need_update = True

    if need_update:
        with open(configfile, 'w') as out:
            if not conf.has_section(section):
                conf.add_section(section)
            conf.set(section, 'url', url)
            conf.write(out)
    
    return auth


def highlight_json(data, indent=2):
    res = highlight(json.dumps(data, indent=indent, ensure_ascii=False),
                    lexers.JsonLexer(),
                    formatters.TerminalFormatter())
    print(res)



CONTEXT_SETTINGS = dict(help_option_names=['-?', '-h', '--help'])


@click.group(name='disease-pipeline-cli', no_args_is_help=True,
             context_settings=CONTEXT_SETTINGS,
             help=click.style('Client for Disease Pipeline', fg='green', bold=True))
@click.option('-u', '--url', help='Cromwell server URL, eg. http://HOST:PORT')
@click.pass_context
def cli(ctx, url):
    
    ctx.ensure_object(dict)
    auth = check_url()
    ctx.obj['auth'] = auth


@cli.command(help='Submit a WDL workflow on Cromwell')
@click.option('-w', '--wdl', help='the main wdl', default=f'{WDL_ROOT}/main.wdl')
@click.option('-i', '--inputs', help='Workflow inputs file')
@click.option('-o', '--options', help='Workflow options file')
@click.option('-l', '--labels', help='Workflow labels file')
@click.option('-v', '--type-version', help='Workflow type version')
@click.option('-p', '--imports', help='A zip file to search for workflow imports', default=f'{WDL_ROOT}/main.zip')
@click.pass_context
def submit(ctx, **kwargs):
    response = cromwell_tools.api.submit(
        ctx.obj['auth'], kwargs['wdl'],
        inputs_files=kwargs['inputs'],
        options_file=kwargs['options'],
        label_file=kwargs['labels'],
        dependencies=[kwargs['imports']])


@cli.command(help='Get the status for given UUID')
@click.option('-id', '--uuid', help='A Cromwell workflow UUID, which is the workflow identifier', required=True)
@click.pass_context
def status(ctx, uuid):
    res = cromwell_tools.api.status(uuid, ctx.obj['auth']).json()
    highlight_json(res)
    res2 = cromwell_tools.api.query({'id': uuid}, ctx.obj['auth']).json()
    highlight_json(res2)


@cli.command(help='Request Cromwell to abort a running workflow by UUID')
@click.option('-id', '--uuid', help='A Cromwell workflow UUID, which is the workflow identifier', required=True)
@click.pass_context
def abort(ctx, uuid):
    res = cromwell_tools.api.abort(uuid, ctx.obj['auth'])
    highlight_json(res.json())


@cli.command(help='Output the timing html for given UUID')
@click.option('-id', '--uuid', help='A Cromwell workflow UUID, which is the workflow identifier', required=True)
@click.option('-o', '--outfile', help='the output filename [stdout]')
@click.pass_context
def timing(ctx, uuid, outfile):
    auth = ctx.obj['auth']
    url = f'{auth.url}/api/workflows/v1/{uuid}/timing'
    response = requests.get(url)

    if response.status_code != 200:
        highlight_json(response.json())
        exit(response.status_code)

    cdnjs = 'https://cdn.jsdelivr.net/npm/jquery@1.11.3/dist/jquery.min.js'
    html = response.text.replace('https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js', cdnjs)

    out = open(outfile, 'w') if outfile else sys.stdout
    with out:
        out.write(html)


@cli.command(help='Get the logs for a workflow')
@click.option('-id', '--uuid', help='A Cromwell workflow UUID, which is the workflow identifier', required=True)
@click.pass_context
def logs(ctx, uuid):
    auth = ctx.obj['auth']
    url = f'{auth.url}/api/workflows/v1/{uuid}/logs'
    response = requests.get(url)
    highlight_json(response.json())



if __name__ == "__main__":
    cli()
