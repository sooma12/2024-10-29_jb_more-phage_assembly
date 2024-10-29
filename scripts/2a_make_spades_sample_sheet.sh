#!/bin/bash
# 2a_make_spades_sample_sheet.sh

source ./config.cfg

# Create .list files with R1 and R2 fastqs.  Sort will put them in same orders, assuming files are paired
find ${READS_FOR_SPADES} -maxdepth 1 -name "${SUBSAMPLES_TO_USE}*.fastq.gz" | grep -e "_R1" | sort > R1.list
find ${READS_FOR_SPADES} -maxdepth 1 -name "${SUBSAMPLES_TO_USE}*.fastq.gz" | grep -e "_R2" | sort > R2.list

if [ -f "${SAMPLE_SHEET_SPADES}" ] ; then
  rm "${SAMPLE_SHEET_SPADES}"
fi

# make sample sheet from R1 and R2 files.  Format on each line looks like (space separated):
# WT_1 /path/to/WT_1_R1.fastq /path/to/WT_1_R2.fastq
# from sample sheet, we can access individual items from each line with e.g. `awk '{print $3}' sample_sheet.txt`

paste R1.list R2.list | while read R1 R2 ;
do
    outdir_root=$(basename ${R2} | cut -f3,4 -d"_")
    sample_line="${outdir_root} ${R1} ${R2}"
    echo "${sample_line}" >> $SAMPLE_SHEET_SPADES
done

rm R1.list R2.list
