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
}

task uncover_stat {
    input {
        File bam
    }

    command <<<
    
    >>>
}
