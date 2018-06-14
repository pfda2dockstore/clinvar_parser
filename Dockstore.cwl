baseCommand: []
class: CommandLineTool
cwlVersion: v1.0
id: clinvar_parser
inputs:
  clinical_significance:
    default: Pathogenic
    doc: Choose between three options
    inputBinding:
      position: 3
      prefix: --clinical_significance
    type: string
  clinvar_file:
    doc: A .txt file from the Clinvar website
    inputBinding:
      position: 1
      prefix: --clinvar_file
    type: File
  goi_list:
    doc: A .txt file containing a list of genes of interest (gene name, chromosome,
      start and stop positions)
    inputBinding:
      position: 2
      prefix: --goi_list
    type: File
label: Clinvar Parser
outputs:
  clinvar_filtered:
    doc: ''
    outputBinding:
      glob: clinvar_filtered/*
    type: File
requirements:
- class: DockerRequirement
  dockerOutputDirectory: /data/out
  dockerPull: pfda2dockstore/clinvar_parser:4
s:author:
  class: s:Person
  s:name: Arturo Pineda
