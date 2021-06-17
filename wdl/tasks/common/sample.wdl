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

        ~{excel2info} --info '~{infile}' --outfile '~{outfile}' --fenqi '~{fenqi}'

        tsv2json -c '#B' -o '~{outfile}.json' '~{outfile}'
    >>>

    output {
        File out = outfile
        File pn = 'pn.txt'
        Array[Map[String, String]] json = read_json('~{outfile}.json')
    }

    meta {
    }

    parameter_meta {
    }
}


task parse_sample_list {
    input {
        File infile
        String comment = '#B'
        String qc_list_out
    }

    command <<<
        set -eo pipefail

        python3 <<CODE
        import json
        import gzip
        from collections import defaultdict

        data = defaultdict(list)

        with open('~{infile}') as f, open('~{qc_list_out}', 'w') as out:
            out.write('#Flowcell_Lane\tPatientID\tSampleID\tLibID\tNovoID\tIndex\tPath\n')
            for line in f:
                linelist = line.strip().split('\t')
                if line.startswith('~{comment}'):
                    continue
                elif line.startswith('#'):
                    title = linelist
                    continue
                context = dict(zip(title, linelist))
                sampleid = context['SampleID']
                libid = context['LibID']
                novoid = context['NovoID']
                path = context['Path']
                lane = context['#Ori_lane']

                fq1 = f'{path}/{libid}/{libid}_L{lane}_1.fq.gz'
                # fq2 = f'{path}/{libid}/{libid}_L{lane}_2.fq.gz'
                # data[sampleid].append([fq1, fq2])

                with gzip.open(fq1) as fq_temp:
                    flowcell = fq_temp.readline().decode().split(':')[2]

                flowcell_lane = f'{flowcell}_L{lane}'

                context['flowcell'] = flowcell
                data[sampleid].append(context)

                linelist[0] = flowcell_lane
                out.write('\t'.join(linelist) + '\n')

        print(json.dumps(data))

        CODE
    >>>

    output {
        Map[String, Array[Map[String, String]]] json = read_json(stdout())
        File sample_list = infile
        File qc_list = qc_list_out
    }
}

