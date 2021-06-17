version 1.0

task fastp {
    input {
        # inputs
        File raw_fq_1
        File raw_fq_2
        String clean_fq_1
        String clean_fq_2
        String outdir = "."

        # params of fastp
        String html
        String json
        Int threads = 4
        Int length_required = 150
        Int n_base_limit = 15
        Int qualified_quality_phred = 5
        Int unqualified_percent_limit = 50

        # params of fastp_convert        
        File fastp_convert_py
        String identity

        # sge
        String mem = "1G"
        String name
    }
    
    command <<<
        set -eo pipefail

        mkdir -p ~{outdir}

        fastp \
            -i ~{raw_fq_1} \
            -I ~{raw_fq_2} \
            -o "~{outdir}/~{clean_fq_1}" \
            -O "~{outdir}/~{clean_fq_2}" \
            -j "~{outdir}/~{json}" \
            -h "~{outdir}/~{html}" \
            -q ~{qualified_quality_phred} \
            -u ~{unqualified_percent_limit} \
            -n ~{n_base_limit} \
            -l ~{length_required} \
            -w ~{threads}

        python "~{fastp_convert_py}" \
            --json "~{outdir}/~{json}" \
            --identity "~{identity}" \
            --pwd "~{outdir}"
    >>>

    output {
        File out_clean_fq_1 = "~{outdir}/~{clean_fq_1}"
        File out_clean_fq_2 = "~{outdir}/~{clean_fq_2}"

        File out_json = "~{outdir}/~{json}"
        File out_html = "~{outdir}/~{html}"

        Array[File] fastp_convert_out = [
            "~{outdir}/~{identity}.stat",
            "~{outdir}/raw_~{identity}.QM",
            "~{outdir}/clean_~{identity}.QM",
            "~{outdir}/raw_~{identity}.GC",
            "~{outdir}/clean_~{identity}.GC",
        ]
    }

    runtime {
        mem: mem
        name: name
    }

    meta {
        description: "quality control with fastp"
        author: "suqingdong <suqingdong@novogene.com>"
    }

    parameter_meta {
        raw_fq_1: {
            description: "the reads one of raw fastq file",
            patterns: ["*fq.gz", "*.fq"]
        }
        raw_fq_2: {
            description: "the reads two of raw fastq file",
            patterns: ["*fq.gz", "*.fq"]
        }
        clean_fq_1: {
            description: "the reads one of clean fastq file",
            patterns: ["*fq.gz", "*.fq"]
        }
        clean_fq_2: {
            description: "the reads two of clean fastq file",
            patterns: ["*fq.gz", "*.fq"]
        }
        outdir: {
            description: "the output directory"
        }

        html: {
            description: "the html format report file name"
        }
        json: {
            description: "the json format report file name"
        }
        threads: {
            description: "worker thread number"
        }
        length_required: {
            description: "reads shorter than length_required will be discarded"
        }
        n_base_limit: {
            description: "if one read's number of N base is >n_base_limit, then this read/pair is discarded"
        }
        qualified_quality_phred: {
            description: "the quality value that a base is qualified"
        }
        unqualified_percent_limit: {
            description: "how many percents of bases are allowed to be unqualified (0~100)"
        }

        fastp_convert_py: {
            description: "the python script of fastp_convert.py"
        }
        identity: {
            description: "the identity parameter for fastp_convert.py"
        }

        mem: {
            description: "the memory for sge"
        }
        name: {
            description: "the name for sge"
        }
    }
}
