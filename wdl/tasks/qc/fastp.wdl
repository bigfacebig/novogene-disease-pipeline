version 1.0

task fastp {
    input {
        File raw_fq_1
        File raw_fq_2
        String clean_fq_1
        String clean_fq_2

        String html
        String json

        # fastp params
        Int threads = 4
        Int min_length = 150
        Int n_base_limit = 15
        Int qualified_quality_phred = 5
        Int unqualified_percent_limit = 50
    }
    
    command <<<
        set -eo pipefail

        mkdir -p "$(dirname ~{clean_fq_1})"

        fastp \
            -i ~{raw_fq_1} \
            -I ~{raw_fq_2} \
            -o ~{clean_fq_1} \
            -O ~{clean_fq_2} \
            -j ~{json} \
            -h ~{html} \
            -q ~{qualified_quality_phred} \
            -u ~{unqualified_percent_limit} \
            -n ~{n_base_limit} \
            -l ~{min_length} \
            -w ~{threads}
    >>>

    output {
        File out_clean_fq_1 = clean_fq_1
        File out_clean_fq_2 = clean_fq_2

        File out_json = json
        File out_html = html
    }

    runtime {
        mem: '2G'
        name: 'qc_fastp'
    }

    meta {
        description: 'quality control with fastp'
        author: 'suqingdong <suqingdong@novogene.com>'
    }

    parameter_meta {
        raw_fq_1: {
            description: 'the reads one for raw fastq file',
            patterns: ['*fq.gz', '*.fq']
        }
        raw_fq_2: {
            description: 'the reads two for raw fastq file',
            patterns: ['*fq.gz', '*.fq']
        }
    }
}


task fastp_convert {
    input {
        File json
        File fastp_convert_py
        String identity
        String pwd = '.'
    }
    
    command <<<
        set -eo pipefail

        mkdir -p "~{pwd}"

        python ~{fastp_convert_py} \
            --json "~{json}" \
            --identity "~{identity}" \
            --pwd "~{pwd}"
    >>>

    runtime {
        mem: '1G'
        name: 'fastp_convert'
    }

    output {
        File stat = '~{pwd}/~{identity}.stat'
        File raw_QM = '~{pwd}/raw_~{identity}.QM'
        File clean_QM = '~{pwd}/clean_~{identity}.QM'
        File raw_GC = '~{pwd}/raw_~{identity}.GC'
        File clean_GC = '~{pwd}/clean_~{identity}.GC'
    }
}
