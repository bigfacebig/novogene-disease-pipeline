version 1.0

import 'tasks/common/sample.wdl' as Sample
import 'tasks/common/md5.wdl' as Md5

import 'tasks/qc/fastp.wdl' as Fastp
import 'tasks/mapping/bwa.wdl' as Bwa
import 'tasks/mapping/sambamba.wdl' as Sambamba
import 'tasks/mapping/alnstat.wdl' as Alnstat


workflow disease {
    input {

        String ROOT_DIR

        String? stagecode

        String? proj_path

        String fenqi_number

        File sample_info_excel

        File sample_list_tsv

        String ref_version = 'b37'
        String ref_fasta

        String seqstrag = 'WES'

        String region_bed
    }


    call Sample.excel2info as excel2info {
        input:
            infile = sample_info_excel,
            fenqi = fenqi_number,
    }

    call Sample.parse_sample_list as parse_sample_list {
        input:
            infile = sample_list_tsv,
            qc_list_out = 'qc_list_~{fenqi_number}',
    }

    scatter ( sample in excel2info.json ) {
        String sampleid = sample['Sampleid']
        scatter ( fq_lane in parse_sample_list.json[sampleid] ) {
            String path = fq_lane['Path']
            String libid = fq_lane['LibID']
            String novoid = fq_lane['NovoID']
            String lane = fq_lane['#Ori_lane']
            String flowcell = fq_lane['flowcell']

            File raw_fq_1 = '~{path}/~{libid}/~{libid}_L~{lane}_1.fq.gz'
            File raw_fq_2 = '~{path}/~{libid}/~{libid}_L~{lane}_2.fq.gz'

            String target1 = 'RawData/~{sampleid}/~{sampleid}_~{novoid}_~{flowcell}_L~{lane}_1.fq.gz'
            String target2 = 'RawData/~{sampleid}/~{sampleid}_~{novoid}_~{flowcell}_L~{lane}_2.fq.gz'

            String identity = '~{sampleid}_~{novoid}_~{flowcell}_L~{lane}'


            scatter ( x in zip([raw_fq_1, raw_fq_2], [target1, target2]) ) {
                call Md5.md5sum as RawdataMD5 {
                    input:
                        source = x.left,
                        target = x.right,
                }
            }
          
            call Fastp.fastp as QC {
                input:
                    raw_fq_1 = raw_fq_1,
                    raw_fq_2 = raw_fq_2,
                    clean_fq_1 = '~{sampleid}_~{novoid}_~{flowcell}_L~{lane}_1.clean.fq.gz',
                    clean_fq_2 = '~{sampleid}_~{novoid}_~{flowcell}_L~{lane}_2.clean.fq.gz',
                    html = '~{sampleid}_~{novoid}_~{flowcell}_L~{lane}.html',
                    json = '~{sampleid}_~{novoid}_~{flowcell}_L~{lane}.json',
                    fastp_convert_py = '~{ROOT_DIR}/scripts/common/fastp_convert.py',
                    identity = identity,
                    outdir = 'QC/~{sampleid}',
                    name = '~{stagecode}__qc-fastp-~{identity}',
            }

            call Bwa.mem as BwaMem {
                input:
                    samtools = 'samtools-1.6',
                    fq1 = QC.out_clean_fq_1,
                    fq2 = QC.out_clean_fq_2,
                    ref_fasta = ref_fasta,
                    sampleid = sampleid,
                    out_prefix = 'Mapping/~{sampleid}.~{sampleid}/~{identity}'
            }
        }

        call Sambamba.merge as SambambaMerge {
            input:
                single = if length(BwaMem.sort_bam) == 1 then true else false,
                input_bams = BwaMem.sort_bam,
                out_bam = 'Mapping/~{sampleid}.~{sampleid}/~{sampleid}.sort.bam',
        }

        call Sambamba.markdup as SambambaMarkdup {
            input:
                input_bam = SambambaMerge.merged_bam,
                out_bam = 'Mapping/~{sampleid}.~{sampleid}/~{sampleid}.nodup.bam',
        }

        call Alnstat.depth_stat as DepthStat {
            input:
                bam = SambambaMerge.merged_bam,
                out_dir= 'Alnstat/~{sampleid}',
                ref_version = ref_version,
                sampleid = sampleid,
                seqstrag = seqstrag,

                depth_stat_perl = '~{ROOT_DIR}/scripts/common/depth_stat.pl',
                region_bed = region_bed,
        }

        call Alnstat.flag_stat as FlagStat {
            input:
                bam = SambambaMarkdup.nodup_bam,
                outfile = 'Alnstat/~{sampleid}/~{sampleid}.flagstat',
                sam_flagstat_py = '~{ROOT_DIR}/scripts/common/sam_flagstat.py',
        }

        call Alnstat.combine_stat as CombineStat {
            input:
                depth_stat = DepthStat.information,
                flag_stat = FlagStat.flag_stat,
                sampleid = sampleid,
                seqstrag = seqstrag,
                outfile = 'Alnstat/~{sampleid}/~{sampleid}_mapping_coverage.txt',
                combine_stat_py = '~{ROOT_DIR}/scripts/common/combine_stat.py',
        }
    }

    parameter_meta {
        ROOT_DIR: {
            description: "the root path of this pipeline"
        }
        stagecode: {
            description: "the stagecode of LIMS"
        }
        fenqi_number: {
            description: "the fenqi number of project, eg. B1"
        }
        sample_info_excel: {
            description: "the sample information file"
        }
        sample_list_tsv: {
            description: "the sample list file"
        }

        ref_version: {
            description: "the version of reference genome",
            patterns: ["b37", "hg38", "mm10", "mm9"]
        }
        ref_fasta: {
            description: "the fasta file of reference genome"
        }

        region_bed: {
            description: "the target region bed file"
        }

        seqstrag: {
            description: "the strategy of sequencing",
            patterns: ["WES", "WGS", "TS"]
        }

    }

    meta {
        description: 'the main workflow pipeline for Disease department'
        author: "suqingdong <suqingdong@novogene.com>"
    }
}
