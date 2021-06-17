version 1.0

import "../tasks/common/md5.wdl"
import "../tasks/qc/fastp.wdl"


workflow quality_control {
    input {
        String? stagecode

        String software = 'fastp'
        File raw_fq_1
        File raw_fq_2
        String clean_fq_1
        String clean_fq_2

        String html
        String json

        String identity
        String pwd = '.'

        File fastp_convert_py
    }

    if ( software == 'fastp' ) {

        call fastp.fastp as qc_fastp {
            input:
                stagecode = stagecode,
                raw_fq_1 = raw_fq_1,
                raw_fq_2 = raw_fq_2,
                clean_fq_1 = clean_fq_1,
                clean_fq_2 = clean_fq_2,
                html = html,
                json = json,
        }

        call fastp.fastp_convert as fastp_convert {
            input:
                stagecode = stagecode,
                fastp_convert_py = fastp_convert_py,
                json = qc_fastp.out_json,
                identity = identity,
                pwd = pwd,
        }
    }

    output {
        File? out_clean_fq_1 = qc_fastp.out_clean_fq_1
        File? out_clean_fq_2 = qc_fastp.out_clean_fq_2
        File? out_html = qc_fastp.out_html
        File? out_json = qc_fastp.out_json

        File? stat = fastp_convert.stat
        File? raw_QM = fastp_convert.raw_QM
        File? clean_QM = fastp_convert.clean_QM
        File? raw_GC = fastp_convert.raw_GC
        File? clean_GC = fastp_convert.clean_GC
    }
}
