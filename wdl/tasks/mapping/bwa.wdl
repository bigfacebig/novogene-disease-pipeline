version 1.0

task mem {
    input {
        String bwa = "bwa"
        String samtools = "samtools"
        String sambamba = "sambamba"
        
        String sampleid

        File fq1
        File fq2

        String out_prefix

        String ref_fasta

        Int threads = 4

        String platform = "illumina"
    }

    command <<<
        set -eo pipefail

        mkdir -p "$(dirname ~{out_prefix})"

        ~{bwa} mem \
            -t ~{threads} -M \
            -R "@RG\\tID:~{sampleid}_$(basename ~{out_prefix})\\tSM:~{sampleid}\\tLB:~{sampleid}\\tPU:$(basename ~{out_prefix})\\tPL:~{platform}\\tCN:Novogene" \
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
        File raw_bam = "~{out_prefix}.raw.bam"
        File sort_bam = "~{out_prefix}.sort.bam"
        File sort_bam_bai = "~{out_prefix}.sort.bam.bai"
    }

    parameter_meta {
        bwa: {
            description: "the bwa executable file or command"
        }
        samtools: {
            description: "the samtools executable file or command"
        }
        sambamba: {
            description: "the sambamba executable file or command"
        }

        threads: {
            description: "use specified number of threads"
        }

        ref_fasta: {
            description: "the fasta file of reference genome"
        }

        sampleid: {
            description: "the sample identity"
        }

        fq1: {
            description: "the reads one of fastq file"
        }
        fq2: {
            description: "the reads two of fastq file"
        }

        out_prefix: {
            description: "the prefix of output files"
        }

        platform: {
            description: "the platform of sequencing"
        }
    }
}