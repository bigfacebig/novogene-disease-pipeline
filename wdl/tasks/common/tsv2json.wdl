version 1.0

task tsv2json {
    input {
        File infile
        String sep = '\t'
        Boolean header = true
        String comment = '#B'
    }

    command <<<
        set -eo pipefail

        tsv2json "~{infile}" \
          -s "~{sep}" \
          ~{true="-H 1" false="-H 0" header} \
          -c '~{comment}'
    >>>

    output {
        Array[Object] json = read_json(stdout())
    }
}
