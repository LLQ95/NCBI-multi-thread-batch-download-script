#!/bin/bash
# script for downloading NCBI genomes and checking（support multi-thread and API key）
# ========== configs========== 
API_KEY="1ef429d37c5d6103dac9cdaec0f54728d009"  # NCBI API key, you can replace it with your own key
INPUT_FILE="accessions.txt"              # input filename
DOWNLOAD_DIR="downloaded_genomes"           # download filename
MAX_PARALLEL=8                              # maximum number of multi-thread
LOG_FILE="download.log"                         # main log
ERROR_LOG="error.log"                           # error log
# =============================
# make download file
mkdir -p "$DOWNLOAD_DIR"
# initialization logfile
exec > >(tee -a "$LOG_FILE") 2> >(tee -a "$ERROR_LOG" >&2)
# check the integrity
check_integrity() {
    local file="$1"
    if ! unzip -tq "$file" >/dev/null 2>&1; then
        echo "file is corrupted: $(basename $file .zip)" >&2
        rm -f "$file"
        return 1
    fi
    return 0
}
# collect the files need to be downloaded (Accession ID)
echo "[$(date +%T)] start checking..."
declare -a missing_accessions
while IFS= read -r accession; do
    accession=$(echo "$accession" | tr -d '\r' | xargs)
    [[ -z "$accession" ]] && continue    
    target_file="${DOWNLOAD_DIR}/${accession}.zip"    
    if [ -f "$target_file" ]; then
        if ! check_integrity "$target_file"; then
            missing_accessions+=("$accession")
        fi
    else
        missing_accessions+=("$accession")
    fi
done < "$INPUT_FILE"
# quit checkingg
if [ ${#missing_accessions[@]} -eq 0 ]; then
    echo "[$(date +%T)] all the files are integrate"
    exit 0
fi
# muti-thread downloaded function
parallel_download() {
    local acc="$1"
    echo "[start downloading] $acc"
# download command（contains API key）
    if datasets download genome accession "$acc" \
        --api-key "$API_KEY" \
        --filename "${DOWNLOAD_DIR}/${acc}.zip" 2>> "$ERROR_LOG"
    then
# check after downloading
        if check_integrity "${DOWNLOAD_DIR}/${acc}.zip"; then
            echo "[successfully download] $acc"
            return 0
        fi
    fi
    echo "[fail to download] $acc" >&2
    return 1
}
# export function and environmental variables for parallel
export -f parallel_download check_integrity
export API_KEY DOWNLOAD_DIR ERROR_LOG
# start downloading in parallel
echo "[$(date +%T)] start downloading in parallel ${#missing_accessions[@]} files..."
printf "%s\n" "${missing_accessions[@]}" | parallel -j $MAX_PARALLEL \
    --progress --bar --eta \
    --joblog "${DOWNLOAD_DIR}/parallel.log" \
    --resume-failed \
    --tagstring "ACC:{}" \
    'parallel_download {}'
# final report
success_count=$(grep -c "successfully download" "$LOG_FILE")
fail_count=$(grep -c "fail to download" "$ERROR_LOG")
echo "==============================="
echo "[final report] download completed time: $(date)"
echo "success: $success_count"
echo "fail: $fail_count"
echo "log_file: $LOG_FILE"
echo "error_log: $ERROR_LOG"
echo "parallel.log: ${DOWNLOAD_DIR}/parallel.log"
