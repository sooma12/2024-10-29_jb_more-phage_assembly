#!/bin/bash
# 1a_make_bbduk_sample_sheet.sh

source ./config.cfg

# Create .list files with R1 and R2 fastqs.  Sort will put them in same orders, assuming files are paired
find ${FASTQ_INPUTS} -maxdepth 1 -name "*.fastq.gz" | grep -e "_R1" | sort > R1.list
find ${FASTQ_INPUTS} -maxdepth 1 -name "*.fastq.gz" | grep -e "_R2" | sort > R2.list

if [ -f "${SAMPLE_SHEET_BBDUK}" ] ; then
  rm "${SAMPLE_SHEET_BBDUK}"
fi

# make sample sheet from R1 and R2 files.  Format on each line looks like (space separated):
# WT_1 /path/to/WT_1_R1.fastq /path/to/WT_1_R2.fastq
# from sample sheet, we can access individual items from each line with e.g. `awk '{print $3}' sample_sheet.txt`

paste R1.list R2.list | while read R1 R2 ;
do
    outdir_root=$(basename ${R2} | cut -f1,2 -d"_")
    sample_line="${outdir_root} ${R1} ${R2}"
    echo "${sample_line}" >> $SAMPLE_SHEET_BBDUK
done

rm R1.list R2.list
