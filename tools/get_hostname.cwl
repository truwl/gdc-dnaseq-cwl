#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

inputs:
  []

outputs:
  - id: output
    type: File
    outputBinding:
      glob: output

stdout: output

baseCommand: "hostname"
