version 1.0


task md5sum {
    input {
        File infile
        String outfile
    }

    String name = basename(infile)

    command <<<
        set -eo pipefail
        
        ln -sf ~{infile} ~{name}

        md5sum ~{name} > ~{outfile}
    >>>

    output {
        File out_md5 = outfile
    }
}


task md5sum_check {
    input {
        File md5_file
    }

    command <<<
        md5sum -c ~{md5_file}
    >>>

    output {
        String check_result = read_string(stdout())
    }
}
