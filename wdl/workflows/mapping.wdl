version 1.0

# import "../tasks/common/md5.wdl"
import "../tasks/mapping/bwa.wdl"


workflow mapping {
    input {
        File? fq1
        File? fq2

        File ref_fasta

        String sampleid
        String out_prefix

        String bwa = 'bwa'
        String samtools = 'samtools'
        String sambamba = 'sambamba'
    }

    call bwa.mem as bwa_mem {
        input:
            fq1 = fq1,
            fq2 = fq2,
            sampleid = sampleid,
            out_prefix = out_prefix,
            ref_fasta = ref_fasta,
            bwa = bwa,
            samtools = samtools,
            sambamba = sambamba,
    }
        
    output {
        File? raw_bam = bwa_mem.raw_bam
        File? sort_bam = bwa_mem.sort_bam
        File? sort_bam_bai = bwa_mem.sort_bam_bai
    }
}
