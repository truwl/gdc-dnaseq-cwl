cwlVersion: v1.0
class: CommandLineTool
id: gatk4_applybqsr
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gatk:4.1.8.aws_fix
  - class: InlineJavascriptRequirement

inputs:
  input:
    format: "edam:format_2572"
    type: File
    inputBinding:
      prefix: --input
    secondaryFiles:
      - ^.bai

  bqsr-recal-file:
    type: File
    inputBinding:
      prefix: --bqsr-recal-file

  emit-original-quals:
    type:
      - type: enum
        symbols: ["true", "false"]
    default: "true"
    inputBinding:
      prefix: --emit-original-quals

  tmp_dir:
    type: string
    default: "."
    inputBinding:
      prefix: --tmp-dir

outputs:
  output_bam:
    format: "edam:format_2572"
    type: File
    outputBinding:
      glob: $(inputs.input.basename)
    secondaryFiles:
      - ^.bai

arguments:
  - valueFrom: $(inputs.input.basename)
    prefix: --output

baseCommand: [java, -jar, /opt/gatk-package-4.1.8.1-8-gfcb7889-SNAPSHOT-local.jar, ApplyBQSR]
