## Inputs

### Required inputs
<p name="disease.fenqi_number">
        <b>disease.fenqi_number</b><br />
        <i>String &mdash; Default: None</i><br />
        the fenqi number of project, eg. B1
</p>
<p name="disease.ref_fasta">
        <b>disease.ref_fasta</b><br />
        <i>String &mdash; Default: None</i><br />
        the fasta file of reference genome
</p>
<p name="disease.ROOT_DIR">
        <b>disease.ROOT_DIR</b><br />
        <i>String &mdash; Default: None</i><br />
        the root path of this pipeline
</p>
<p name="disease.sample_info_excel">
        <b>disease.sample_info_excel</b><br />
        <i>File &mdash; Default: None</i><br />
        the sample information file
</p>
<p name="disease.sample_list_tsv">
        <b>disease.sample_list_tsv</b><br />
        <i>File &mdash; Default: None</i><br />
        the sample list file
</p>

### Other inputs
<details>
<summary> Show/Hide </summary>
<p name="disease.BwaMem.bwa">
        <b>disease.BwaMem.bwa</b><br />
        <i>String &mdash; Default: 'bwa'</i><br />
        ???
</p>
<p name="disease.BwaMem.sambamba">
        <b>disease.BwaMem.sambamba</b><br />
        <i>String &mdash; Default: 'sambamba'</i><br />
        ???
</p>
<p name="disease.BwaMem.threads">
        <b>disease.BwaMem.threads</b><br />
        <i>Int &mdash; Default: 4</i><br />
        ???
</p>
<p name="disease.excel2info.excel2info">
        <b>disease.excel2info.excel2info</b><br />
        <i>String &mdash; Default: 'excel2info'</i><br />
        ???
</p>
<p name="disease.excel2info.outfile">
        <b>disease.excel2info.outfile</b><br />
        <i>String &mdash; Default: 'sample_info_~{fenqi}'</i><br />
        ???
</p>
<p name="disease.parse_sample_list.comment">
        <b>disease.parse_sample_list.comment</b><br />
        <i>String &mdash; Default: '#B'</i><br />
        ???
</p>
<p name="disease.proj_path">
        <b>disease.proj_path</b><br />
        <i>String? &mdash; Default: None</i><br />
        ???
</p>
<p name="disease.QC.length_required">
        <b>disease.QC.length_required</b><br />
        <i>Int &mdash; Default: 150</i><br />
        reads shorter than length_required will be discarded
</p>
<p name="disease.QC.mem">
        <b>disease.QC.mem</b><br />
        <i>String &mdash; Default: "1G"</i><br />
        the memory for sge
</p>
<p name="disease.QC.n_base_limit">
        <b>disease.QC.n_base_limit</b><br />
        <i>Int &mdash; Default: 15</i><br />
        if one read's number of N base is >n_base_limit, then this read/pair is discarded
</p>
<p name="disease.QC.qualified_quality_phred">
        <b>disease.QC.qualified_quality_phred</b><br />
        <i>Int &mdash; Default: 5</i><br />
        the quality value that a base is qualified
</p>
<p name="disease.QC.threads">
        <b>disease.QC.threads</b><br />
        <i>Int &mdash; Default: 4</i><br />
        worker thread number
</p>
<p name="disease.QC.unqualified_percent_limit">
        <b>disease.QC.unqualified_percent_limit</b><br />
        <i>Int &mdash; Default: 50</i><br />
        how many percents of bases are allowed to be unqualified (0~100)
</p>
<p name="disease.RawdataMD5.md5_out">
        <b>disease.RawdataMD5.md5_out</b><br />
        <i>String &mdash; Default: '~{target}.MD5.txt'</i><br />
        the output filename
</p>
<p name="disease.ref_version">
        <b>disease.ref_version</b><br />
        <i>String &mdash; Default: 'b37'</i><br />
        the version of reference genome
</p>
<p name="disease.region_bed">
        <b>disease.region_bed</b><br />
        <i>String &mdash; Default: '/ifs/TJPROJ3/DISEASE/Database/Exome_bed/Agilent/SureSelectXT.Human.All.Exon.V6/S07604514_Regions_extract.bed'</i><br />
        the target region bed file
</p>
<p name="disease.SambambaMarkdup.nthreads">
        <b>disease.SambambaMarkdup.nthreads</b><br />
        <i>Int &mdash; Default: 4</i><br />
        ???
</p>
<p name="disease.SambambaMarkdup.tmpdir">
        <b>disease.SambambaMarkdup.tmpdir</b><br />
        <i>String &mdash; Default: 'tmp'</i><br />
        ???
</p>
<p name="disease.SambambaMerge.nthreads">
        <b>disease.SambambaMerge.nthreads</b><br />
        <i>Int &mdash; Default: 4</i><br />
        ???
</p>
<p name="disease.seqstrag">
        <b>disease.seqstrag</b><br />
        <i>String &mdash; Default: 'WES'</i><br />
        the strategy of sequencing
</p>
<p name="disease.stagecode">
        <b>disease.stagecode</b><br />
        <i>String? &mdash; Default: None</i><br />
        the stagecode of LIMS
</p>
</details>






<hr />

> Generated using WDL AID (0.1.1)
