version 1.0

task mem {
    input {
        String bwa = 'bwa'
        String samtools = 'samtools'
        String sambamba = 'sambamba'
        
        String sampleid

        File? fq1
        File? fq2

        String out_prefix

        String ref_fasta

        Int threads = 4
    }

    command <<<
        set -eo pipefail

        mkdir -p "$(dirname ~{out_prefix})"

        ~{bwa} mem \
            -t ~{threads} -M \
            -R "@RG\\tID:~{sampleid}_$(basename ~{out_prefix})\\tSM:~{sampleid}\\tLB:~{sampleid}\\tPU:$(basename ~{out_prefix})\\tPL:illumina\\tCN:Novogene" \
            ~{ref_fasta} \
            ~{fq1} ~{fq2} |
        ~{samtools} view \
            -@ ~{threads} \
            -b -S \
            -t ~{ref_fasta}.fai \
            -o ~{out_prefix}.raw.bam

        ~{sambamba} sort \
            -t ~{threads} \
            -m 4G \
            --tmpdir $(basename ~{out_prefix}).tmp \
            -o ~{out_prefix}.sort.bam \
            ~{out_prefix}.raw.bam
    >>>

    output {
        File raw_bam = '~{out_prefix}.raw.bam'
        File sort_bam = '~{out_prefix}.sort.bam'
        File sort_bam_bai = '~{out_prefix}.sort.bam.bai'
    }
}