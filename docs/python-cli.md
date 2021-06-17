```bash
python3 -m pip install -r requirements.txt

python3 cli/main.py -h
```

```
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
```

#### `submit`
```bash
python3 cli/main.py submit -h
```

```
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
```

#### `status`
```bash
python3 cli/main.py status -h
```
```
Usage: main.py status [OPTIONS]

  Get the status for given UUID

Options:
  -id, --uuid TEXT  A Cromwell workflow UUID, which is the workflow identifier
                    [required]

  -?, -h, --help    Show this message and exit.
```

#### `timing`
```bash
python3 cli/main.py timing -h
```

```
Usage: main.py timing [OPTIONS]

  Output the timing html for given UUID

Options:
  -id, --uuid TEXT    A Cromwell workflow UUID, which is the workflow
                      identifier  [required]

  -o, --outfile TEXT  the output filename [stdout]
  -h, -?, --help      Show this message and exit.
```
[timing-demo.html](./assets/timing-demo.html)