---
layout: default
title: Home
---

> Novogene Disease Pipeline with WDL

## Usage
### 1. run with cromwell
```bash

java -jar cromwell-<version>.jar run \
    -i inputs.json \
    -o options.json \
    -l labels.json \
    --imports /path/to/main.zip \
    path/to/mail.wdl
```

- `inputs.json` could be generated with `womtool`

```bash
java -jar womtool-<version>.jar inputs path/to/main.wdl > inputs.json
```
> [inputs details](./inputs.html)

- `options.json` example:

```json
{
    "final_workflow_outputs_dir": "proj_test",
    "final_workflow_log_dir": "proj_test/logs",
    "use_relative_output_paths": true,
    "write_to_cache": true,
    "read_from_cache": true
}
```

### 2. submit with cromwell
#### start a server with cromwell
```
java -Dconfig.file=sge.conf -jar cromwell-<version>.jar server
```
> config example: [sge.conf](../config/cromwell/sge.conf)

#### submit to server
```
java -jar cromwell-<version>.jar submit \
    -h http://<HOST>:<PORT> \
    -i inputs.json \
    -o options.json \
    --imports /path/to/main.zip \
    path/to/mail.wdl
```

### 3. run with Python
```
python3 -m pip install -r requirements.txt

python3 cli/main.py -h
```
<details>
<summary>show/hide</summary>
<pre>
Usage: main.py [OPTIONS] COMMAND [ARGS]...

  Client for Disease Pipeline

Options:
  -u, --url TEXT  Cromwell server URL, eg. http://HOST:PORT
  -?, -h, --help  Show this message and exit.

Commands:
  abort   Request Cromwell to abort a running workflow by UUID
  logs    Get the logs for a workflow
  status  Get the status for given UUID
  submit  Submit a WDL workflow on Cromwell
  timing  Output the timing html for given UUID
</pre>
</details>


#### `submit`
```bash
python3 cli/main.py submit -h
```
<details>
<summary>show/hide</summary>
<pre>
Usage: main.py submit [OPTIONS]

  Submit a WDL workflow on Cromwell

Options:
  -w, --wdl TEXT           the main wdl
  -i, --inputs TEXT        Workflow inputs file
  -o, --options TEXT       Workflow options file
  -l, --labels TEXT        Workflow labels file
  -v, --type-version TEXT  Workflow type version
  -p, --imports TEXT       A zip file to search for workflow imports
  -?, -h, --help           Show this message and exit.
</pre>
</details>

#### `status`
```bash
python3 cli/main.py status -h
```
<details>
<summary>show/hide</summary>
<pre>
Usage: main.py status [OPTIONS]

  Get the status for given UUID

Options:
  -id, --uuid TEXT  A Cromwell workflow UUID, which is the workflow identifier
                    [required]

  -?, -h, --help    Show this message and exit.
</pre>
</details>