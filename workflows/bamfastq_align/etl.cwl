#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: ../../tools/amplicon_kit.yml
      - $import: ../../tools/capture_kit.yml
      - $import: ../../tools/readgroup.yml
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: bam_name
    type: string
  - id: bioclient_config
    type: File
  - id: bioclient_load_bucket
    type: string
  - id: job_uuid
    type: string
  - id: amplicon_kit_set_uuid_list
    type:
      type: array
      items: ../../tools/amplicon_kit.yml#amplicon_kit_set_uuid
  - id: capture_kit_set_uuid_list
    type:
      type: array
      items: ../../tools/capture_kit.yml#capture_kit_set_uuid
  - id: readgroup_fastq_pe_uuid_list
    type:
      type: array
      items:  ../../tools/readgroup.yml#readgroup_fastq_pe_uuid
  - id: readgroup_fastq_se_uuid_list
    type:
      type: array
      items:  ../../tools/readgroup.yml#readgroup_fastq_se_uuid
  - id: readgroups_bam_uuid_list
    type: 
      type: array
      items: ../../tools/readgroup.yml#readgroups_bam_uuid
  - id: start_token
    type: ["null", File]
  - id: common_biallelic_vcf_gdc_id
    type: string
  - id: common_biallelic_vcf_file_size
    type: long    
  - id: common_biallelic_vcf_index_gdc_id
    type: string
  - id: common_biallelic_vcf_index_file_size
    type: long    
  - id: known_snp_gdc_id
    type: string
  - id: known_snp_file_size
    type: long
  - id: known_snp_index_gdc_id
    type: string
  - id: known_snp_index_file_size
    type: long
  - id: reference_amb_gdc_id
    type: string
  - id: reference_amb_file_size
    type: long
  - id: reference_ann_gdc_id
    type: string
  - id: reference_ann_file_size
    type: long
  - id: reference_bwt_gdc_id
    type: string
  - id: reference_bwt_file_size
    type: long
  - id: reference_dict_gdc_id
    type: string
  - id: reference_dict_file_size
    type: long
  - id: reference_fa_gdc_id
    type: string
  - id: reference_fa_file_size
    type: long
  - id: reference_fai_gdc_id
    type: string
  - id: reference_fai_file_size
    type: long
  - id: reference_pac_gdc_id
    type: string
  - id: reference_pac_file_size
    type: long
  - id: reference_sa_gdc_id
    type: string
  - id: reference_sa_file_size
    type: long
  - id: sq_header_gdc_id
    type: string
  - id: sq_header_file_size
    type: long
  - id: run_bamindex
    type:
      type: array
      items: long
  - id: run_markduplicates
    type:
      type: array
      items: long
  - id: thread_count
    type: long

outputs:
  - id: indexd_bam_uuid
    type: string
    outputSource: emit_bam_uuid/output
  - id: indexd_bai_uuid
    type: string
    outputSource: emit_bai_uuid/output
  - id: indexd_sqlite_uuid
    type: string
    outputSource: emit_sqlite_uuid/output

steps:
  - id: extract_readgroup_fastq_pe
    run: extract_readgroup_fastq_pe.cwl
    scatter: readgroup_fastq_pe_uuid
    in:
      - id: readgroup_fastq_pe_uuid
        source: readgroup_fastq_pe_uuid_list
      - id: bioclient_config
        source: bioclient_config
    out:
      - id: output

  - id: extract_readgroup_fastq_se
    run: extract_readgroup_fastq_se.cwl
    scatter: readgroup_fastq_se_uuid
    in:
      - id: readgroup_fastq_se_uuid
        source: readgroup_fastq_se_uuid_list
      - id: bioclient_config
        source: bioclient_config
    out:
      - id: output

  - id: extract_readgroups_bam
    run: extract_readgroups_bam.cwl
    scatter: [readgroups_bam_uuid]
    in:
      - id: readgroups_bam_uuid
        source: readgroups_bam_uuid_list
      - id: bioclient_config
        source: bioclient_config
    out:
      - id: output

  - id: extract_amplicon_kits
    run: extract_amplicon_kit.cwl
    scatter: amplicon_kit_set_uuid
    in:
      - id: bioclient_config
        source: bioclient_config
      - id: amplicon_kit_set_uuid
        source: amplicon_kit_set_uuid_list
    out:
      - id: output

  - id: extract_capture_kits
    run: extract_capture_kit.cwl
    scatter: capture_kit_set_uuid
    in:
      - id: bioclient_config
        source: bioclient_config
      - id: capture_kit_set_uuid
        source: capture_kit_set_uuid_list
    out:
      - id: output

  - id: extract_common_biallelic_vcf
    run: ../../tools/bio_client_download.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: common_biallelic_vcf_gdc_id
      - id: file_size
        source: common_biallelic_vcf_file_size
    out:
      - id: output

  - id: extract_common_biallelic_vcf_index
    run: ../../tools/bio_client_download.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: common_biallelic_vcf_index_gdc_id
      - id: file_size
        source: common_biallelic_vcf_index_file_size
    out:
      - id: output

  - id: extract_known_snp
    run: ../../tools/bio_client_download.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: known_snp_gdc_id
      - id: file_size
        source: known_snp_file_size
    out:
      - id: output

  - id: extract_known_snp_index
    run: ../../tools/bio_client_download.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: known_snp_index_gdc_id
      - id: file_size
        source: known_snp_index_file_size
    out:
      - id: output

  - id: extract_reference_amb
    run: ../../tools/bio_client_download.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: reference_amb_gdc_id
      - id: file_size
        source: reference_amb_file_size
    out:
      - id: output

  - id: extract_reference_ann
    run: ../../tools/bio_client_download.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: reference_ann_gdc_id
      - id: file_size
        source: reference_ann_file_size
    out:
      - id: output

  - id: extract_reference_bwt
    run: ../../tools/bio_client_download.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: reference_bwt_gdc_id
      - id: file_size
        source: reference_bwt_file_size
    out:
      - id: output

  - id: extract_reference_dict
    run: ../../tools/bio_client_download.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: reference_dict_gdc_id
      - id: file_size
        source: reference_dict_file_size
    out:
      - id: output

  - id: extract_reference_fa
    run: ../../tools/bio_client_download.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: reference_fa_gdc_id
      - id: file_size
        source: reference_fa_file_size
    out:
      - id: output

  - id: extract_reference_fai
    run: ../../tools/bio_client_download.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: reference_fai_gdc_id
      - id: file_size
        source: reference_fai_file_size
    out:
      - id: output

  - id: extract_reference_pac
    run: ../../tools/bio_client_download.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: reference_pac_gdc_id
      - id: file_size
        source: reference_pac_file_size
    out:
      - id: output

  - id: extract_reference_sa
    run: ../../tools/bio_client_download.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: reference_sa_gdc_id
      - id: file_size
        source: reference_sa_file_size
    out:
      - id: output

  - id: extract_sq_header
    run: ../../tools/bio_client_download.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: sq_header_gdc_id
      - id: file_size
        source: sq_header_file_size
    out:
      - id: output

  - id: root_fasta_files
    run: ../../tools/root_fasta_dnaseq.cwl
    in:
      - id: fasta
        source: extract_reference_fa/output
      - id: fasta_amb
        source: extract_reference_amb/output
      - id: fasta_ann
        source: extract_reference_ann/output
      - id: fasta_bwt
        source: extract_reference_bwt/output
      - id: fasta_dict
        source: extract_reference_dict/output
      - id: fasta_fai
        source: extract_reference_fai/output
      - id: fasta_pac
        source: extract_reference_pac/output
      - id: fasta_sa
        source: extract_reference_sa/output
    out:
      - id: output

  - id: root_common_biallelic_vcf_files
    run: ../../tools/root_vcf.cwl
    in:
      - id: vcf
        source: extract_common_biallelic_vcf/output
      - id: vcf_index
        source: extract_common_biallelic_vcf_index/output
    out:
      - id: output
 
  - id: root_known_snp_files
    run: ../../tools/root_vcf.cwl
    in:
      - id: vcf
        source: extract_known_snp/output
      - id: vcf_index
        source: extract_known_snp_index/output
    out:
      - id: output
 
  - id: transform
    run: transform.cwl
    in:
      - id: bam_name
        source: bam_name
      - id: job_uuid
        source: job_uuid
      - id: amplicon_kit_set_file_list
        source: extract_amplicon_kits/output
      - id: capture_kit_set_file_list
        source: extract_capture_kits/output
      - id: readgroup_fastq_pe_file_list
        source: extract_readgroup_fastq_pe/output
      - id: readgroup_fastq_se_file_list
        source: extract_readgroup_fastq_se/output
      - id: readgroups_bam_file_list
        source: extract_readgroups_bam/output
      - id: common_biallelic_vcf
        source: root_common_biallelic_vcf_files/output
      - id: known_snp
        source: root_known_snp_files/output
      - id: reference_sequence
        source: root_fasta_files/output
      - id: run_bamindex
        source: run_bamindex
      - id: run_markduplicates
        source: run_markduplicates
      - id: sq_header
        source: extract_sq_header/output
      - id: thread_count
        source: thread_count
    out:
      - id: output_bam
      - id: sqlite

  - id: load_bam
    run: ../../tools/bio_client_upload_pull_uuid.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: input
        source: transform/output_bam
      - id: upload-bucket
        source: bioclient_load_bucket
      - id: upload-key
        valueFrom: $(inputs.job_uuid)/$(inputs.input.basename)
      - id: job_uuid
        source: job_uuid
        valueFrom: $(null)
    out:
      - id: output

  - id: load_bai
    run: ../../tools/bio_client_upload_pull_uuid.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: input
        source: transform/output_bam
        valueFrom: $(self.secondaryFiles[0])
      - id: upload-bucket
        source: bioclient_load_bucket
      - id: upload-key
        valueFrom: $(inputs.job_uuid)/$(inputs.input.nameroot).bai
      - id: job_uuid
        source: job_uuid
        valueFrom: $(null)
    out:
      - id: output

  - id: load_sqlite
    run: ../../tools/bio_client_upload_pull_uuid.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: input
        source: transform/sqlite
      - id: upload-bucket
        source: bioclient_load_bucket
      - id: upload-key
        valueFrom: $(inputs.job_uuid)/$(inputs.input.basename)
      - id: job_uuid
        source: job_uuid
        valueFrom: $(null)
    out:
      - id: output

  - id: emit_bam_uuid
    run: ../../tools/emit_json_value.cwl
    in:
      - id: input
        source: load_bam/output
      - id: key
        valueFrom: did
    out:
      - id: output

  - id: emit_bai_uuid
    run: ../../tools/emit_json_value.cwl
    in:
      - id: input
        source: load_bai/output
      - id: key
        valueFrom: did
    out:
      - id: output

  - id: emit_sqlite_uuid
    run: ../../tools/emit_json_value.cwl
    in:
      - id: input
        source: load_sqlite/output
      - id: key
        valueFrom: did
    out:
      - id: output
