# NanoHLA: A method for human leukocyte antigen class I genes typing without error correction based on nanopore sequencing data

NanoHLA is a method for typing HLA class I genes without error correction based on nanopore sequencing data. This method not only enables high-resolution typing of HLA class I genes but also allows precise and high-resolution typing with smaller data size when the sequencing data have a high sequencing accuracy and a longer sequencing read length. We hope that NanoHLA will provide tools and solutions for use in related fields and look forward to further expanding the application of nanopore sequencing technology in both research and clinical settings.

Option

                <nanopore_fastq_prefix>     Prefix of raw nanopore sequencing fastq file, format: prefix.fastq
                <hla_type_config>           Detected HLA type file, required absolute path
                <nano2ngs_parametre>        Nano2ngs used parametre
                <script_path>               Script absolute path


Example: <br />
**sh auto_pipeline.sh Sample Absolute-Path/HLA-Type.config "-read_len 100 -time 10" Absolute-Path/NanoHLA**

Note: <br />
1. Users should put the shell scripts and raw_data folder in the same directory. Otherwise, please modify the path where the fastq file stored in the shell script. <br />
2. The method is still under further optimization and development, please contact us if you have any good suggestions and questions.<br />
***Contact and E-mail: langjidong@hotmail.com***
