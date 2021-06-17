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

- `labels.json` example:

```json
{
  "stagecode": "X101XXXX",
  "owner": "suqingdong"
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
    -l labels.json \
    --imports /path/to/main.zip \
    path/to/mail.wdl
```

### 3. run with Python
{% include_relative python-cli.md %}

