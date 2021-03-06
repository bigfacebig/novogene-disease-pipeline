version 1.0

task merge {
    input {
        Array[File]+ input_bams
        String out_bam
        Int nthreads = 4
        Boolean single = false
    }

    command <<<
        set -eo pipefail

        mkdir -p "$(dirname ~{out_bam})"

        if [ ~{single} ];then
            ln -sf ~{sep=' ' input_bams} ~{out_bam}
            sambamba index ~{out_bam}
        else
            sambamba merge \
                -t ~{nthreads} \
                ~{out_bam} \
                ~{sep=' ' input_bams}
        fi
    >>>

    output {
        File merged_bam = out_bam
        File merged_bam_bai = '~{out_bam}.bai'
    }

    parameter_meta {
        input_bams: {
            description: "the files array of input bams"
        }
        out_bam: {
            description: "the output bam"
        }
        nthreads: {
            description: "the number of threads to use"
        }
        single: {
            description: "input bams is sigle or not"
        }
    }
}

task markdup {
    input {
        File input_bam
        String out_bam
        Int nthreads = 4
        String tmpdir = 'tmp'
    }

    command <<<
        set -eo pipefail

        mkdir -p "$(dirname ~{out_bam})"

        sambamba markdup \
            -t ~{nthreads} \
            --overflow-list-size=10000000 \
            --tmpdir=~{tmpdir} \
            ~{input_bam} \
            ~{out_bam}
    >>>

    output {
        File nodup_bam = out_bam
        File nodup_bam_bai = '~{out_bam}.bai'
    }

    parameter_meta {
        input_bam: {
            description: "the input bam"
        }
        out_bam: {
            description: "the output bam"
        }
        nthreads: {
            description: "the number of threads to use"
        }
        tmpdir: {
            description: "the temp directory"
        }
    }
}