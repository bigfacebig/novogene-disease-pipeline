version 1.0

task excel2info {
    input {
        File infile

        String fenqi
        String outfile = 'sample_info_~{fenqi}'

        # File excel2info_py = '../../scripts/common/excel2info.py'
        String excel2info = 'excel2info'
    }

    command <<<
        set -eo pipefail

        ~{excel2info} --info ~{infile} --outfile ~{outfile} --fenqi ~{fenqi}
    >>>

    output {
        File out = outfile
    }

    meta {
    }

    parameter_meta {
    }
}
