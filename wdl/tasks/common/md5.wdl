version 1.0


task md5sum {
    input {
        File source
        String target = basename(source)
        String md5_out = '~{target}.MD5.txt'
    }

    command <<<
        set -eo pipefail
        
        mkdir -p "$(dirname ~{target})"

        ln -sf ~{source} ~{target}

        md5sum ~{target} > ~{md5_out}
    >>>

    output {
        File out = target
        File md5 = md5_out
    }

    meta {
        description: 'run md5sum for input file'
    }

    parameter_meta {
        # inputs
        source: {
            description: 'the source file',
            category: 'required'
        }
        target: {
            description: 'the target file of soft-link',
            category: 'common'
        }
        md5_out: {
            description: 'the output filename',
            catagory: 'common'
        }
    }
}


# task md5sum_check {
#     input {
#         File infile
#         File md5_file
#     }

#     command <<<
#         set -eo pipefail

#         ln -sf ~{infile} $(basename ~{infile})

#         md5sum -c ~{md5_file}
#     >>>

#     output {
#         String result = read_string(stdout())
#     }
# }
