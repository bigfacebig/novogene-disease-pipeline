version 1.0

task ParseSampleInfo {
    input {
        File sample_info
        String outfile
    }

    command <<<
        ~{excel2info} -info ~{sample_info} -o {outfile}
    >>>

    output {
        File out = outfile
    }

    meta {

    }

    parameter_meta {

    }
}
