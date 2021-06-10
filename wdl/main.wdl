version 1.0

import 'workflows/qc.wdl' as QC
import 'workflows/mapping.wdl' as Mapping


workflow main {
    input {
        File? sample_info_excel
        String? proj_path

        String ref_version = 'b37'

        String qc_software = 'fastp'

    }

    call QC.quality_control as QC  {
        input:
            software = qc_software,
    }

    call Mapping.mapping as Mapping {
        input:
            fq1 = QC.out_clean_fq_1,
            fq2 = QC.out_clean_fq_2,
    }

    # # call tasks
    # Array[String] sample_list = ['s1', 's2', 's3', 's4']

    # scatter(sampleid in sample_list) {
    #     call QC.quality_control as QC  {
    #         input:
    #             identity = sampleid,
    #             raw_fq_1 = raw_fq_1,
    #             raw_fq_2 = raw_fq_2,
    #             clean_fq_1 = clean_fq_1,
    #             clean_fq_2 = clean_fq_2
    #     }
    # }

    parameter_meta {
        proj_path: {
            description: "the path of project"
        }
        ref_version: {
            description: "the version of reference genome",
            patterns: ['b37', 'hg38', 'mm10', 'mm9']
        }

    }

    meta {
        description: 'the main workflow of pipeline'
    }
}