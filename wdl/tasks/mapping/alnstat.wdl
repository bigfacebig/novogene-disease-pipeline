version 1.0

task depth_stat {
    input {
        File bam
        String out_dir
        String ref_version
        String sampleid
        String seqstrag

        File depth_stat_perl
        File? region_bed
    }

    String target = if seqstrag == 'WGS' then "" else "-r " + region_bed

    command <<<
        set -eo pipefail

        mkdir -p ~{out_dir}

        perl ~{depth_stat_perl} \
            -s ~{sampleid} \
            -g ~{ref_version} \
            ~{bam} \
            ~{target} \
            ~{out_dir}
    >>>

    output {
        Array[File] depth_stat = [
            '~{out_dir}/cumu.xls',
            '~{out_dir}/depth_frequency.xls',
            '~{out_dir}/SD_MD.xls',
            '~{out_dir}/~{sampleid}.coverage.bychr.txt',
        ]
        File information ='~{out_dir}/information.xlsx'
    }

    parameter_meta {
        bam: {
            description: "the input bam"
        }
        out_dir: {
            description: "the output directory"
        }
        ref_version: {
            description: "the version of reference genome"
        }
        sampleid: {
            description: "the identity of sample"
        }
        seqstrag:{
            description: "the strategy of sequencing"
        }

        depth_stat_perl: {
            description: "the path of depth_stat.pl script"
        }
        region_bed: {
            description: "the region bed file, not needed for WGS"
        }
    }
}


task flag_stat {
    input {
        File bam
        String outfile

        File sam_flagstat_py
    }

    command <<<
        set -eo pipefail

        mkdir -p "$(dirname ~{outfile})"

        python ~{sam_flagstat_py} \
            --bam ~{bam} \
            > ~{outfile}
    >>>

    output {
        File flag_stat = outfile
    }

    parameter_meta {
        bam: {
            description: "the input bam"
        }
        outfile: {
            description: "the output filename"
        }
        sam_flagstat_py: {
            description: "the path of sam_flagstat.py script"
        }
    }
}


task combine_stat {
    input {
        File depth_stat
        File flag_stat
        String sampleid
        String outfile
        String seqstrag
        File combine_stat_py
    }

    command <<<
        set -eo pipefail
        
        mkdir -p "$(dirname ~{outfile})"
        
        python ~{combine_stat_py} \
            ~{depth_stat} \
            ~{flag_stat} \
            ~{sampleid} \
            ~{seqstrag} \
            > ~{outfile}
    >>>

    output {
        File stat = outfile
    }

    parameter_meta {
        depth_stat: {
            description: "the result of depth_stat"
        }
        flag_stat: {
            description: "the result of flag_stat"
        }
        sampleid: {
            description: "the identity of sample"
        }
        outfile: {
            description: "the output filename"
        }
        seqstrag:{
            description: "the strategy of sequencing"
        }
        combine_stat_py: {
            description: "the path of combine_stat.py script"
        }
    }
}

task uncover_stat {
    input {
        File bam
    }

    command <<<
    
    >>>
}
