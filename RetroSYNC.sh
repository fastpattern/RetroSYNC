#!/bin/bash
#@fastpattern-test
###################################################################################################################################################
#             CREATE + VALIDATE LOCAL DIRECTORY STRUCTURE                                                                                         #
###################################################################################################################################################
# list of directories to be validated or created for script execution
directories=(
#import directory is where all raw save files will be downloaded to
    $HOME/gamesaves/import
    $HOME/gamesaves/import/mcp1
    $HOME/gamesaves/import/mcp2
    $HOME/gamesaves/import/mister/gba
    $HOME/gamesaves/import/mister/n64
    $HOME/gamesaves/import/mister/psx
    $HOME/gamesaves/import/mister/snes
    $HOME/gamesaves/import/nas/gba
    $HOME/gamesaves/import/nas/n64
    $HOME/gamesaves/import/nas/psx
    $HOME/gamesaves/import/nas/snes
#saves from 'import' will be renamed for consistency/comparison and placed into 'reconciled'
    $HOME/gamesaves/reconciled
    $HOME/gamesaves/reconciled/mcp1
    $HOME/gamesaves/reconciled/mcp2
    $HOME/gamesaves/reconciled/mister/gba
    $HOME/gamesaves/reconciled/mister/n64
    $HOME/gamesaves/reconciled/mister/psx
    $HOME/gamesaves/reconciled/mister/snes
    $HOME/gamesaves/reconciled/nas/gba
    $HOME/gamesaves/reconciled/nas/n64
    $HOME/gamesaves/reconciled/nas/psx
    $HOME/gamesaves/reconciled/nas/snes
#saves from 'reconciled' will be compared with the newest save for each game/platform placed in 'master' to create a 'master list' of saves
    $HOME/gamesaves/master
    $HOME/gamesaves/master/psx
    $HOME/gamesaves/master/gba
    $HOME/gamesaves/master/n64
    $HOME/gamesaves/master/snes
#saves from 'master' will be renamed appropriately for each device/platform type and copied to 'export'. These are the saves that will be uploaded back to each device.
    $HOME/gamesaves/export
    $HOME/gamesaves/export/mcp1
    $HOME/gamesaves/export/mcp2
    $HOME/gamesaves/export/mister/gba
    $HOME/gamesaves/export/mister/n64
    $HOME/gamesaves/export/mister/psx
    $HOME/gamesaves/export/mister/snes
    $HOME/gamesaves/export/nas/gba
    $HOME/gamesaves/export/nas/n64
    $HOME/gamesaves/export/nas/psx
    $HOME/gamesaves/export/nas/snes
#'system' is where files needed for script execution (such as CSVs) will be placed
    $HOME/gamesaves/system
)

for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "Creating directory: $dir"
        mkdir -p "$dir"
        chmod 775 "$dir"
        echo "Setting permissions to 775 for directory: $dir"
    else
        echo "Directory already exists: $dir"
        # Get current permissions in octal format
        current_perms=$(stat -c "%a" "$dir")
        # Desired permissions
        desired_perms="775"
        if [ "$current_perms" != "$desired_perms" ]; then
            echo "Adjusting permissions for $dir"
            chmod 775 "$dir"
            echo "Permissions adjusted to 775 for directory: $dir"
        else
            echo "Permissions for $dir are already set correctly."
        fi
    fi
done
###################################################################################################################################################
#             DEVICE CONFIGURATION                                                                                                                #
###################################################################################################################################################
###################################################################################################################################################
#             CSV File for PSX GameID Conversion                                                                                                  #
###################################################################################################################################################
CSV_FILE="$HOME/gamesaves/system/PSX_titles.csv"

# this file is needed for PSX Game ID mapping, we can get it from GitHub if it's missing
csv_file_psx="$HOME/gamesaves/system/PSX_titles.csv"
psx_csv_download="https://raw.githubusercontent.com/fastpattern/RetroSYNC/main/PSX_titles.csv"

if [ ! -f "$csv_file_psx" ]; then
    echo "File does not exist. Downloading from GitHub..."
    wget -O "$csv_file_psx" "$psx_csv_download"
    echo "Download completed."
else
    echo "PSX CSV already exists."
fi
###################################################################################################################################################
#             MemCard Pro 1 CONFIGURATION                                                                                                         #
###################################################################################################################################################
MCP1_IP="0.0.0.0"
# save path on MCP1 where PSX saves will be downloaded from
MCP1_SAVE_PATH="/MemoryCards"
# local path where PSX saves will be downloaded to
MCP1_DOWNLOAD_LOCAL_PATH="$HOME/gamesaves/import/mcp1"
# local path where renamed PSX saves will be copied to
MCP1_RECONCILE_PATH="$HOME/gamesaves/reconciled/mcp1"
# local path where latest saves will be prepared for export back to MCP1
MCP1_EXPORT_PATH="$HOME/gamesaves/export/mcp1"
MCP1_USERNAME="username"
MCP1_PASSWORD="password"
###################################################################################################################################################
#             MemCard Pro 2 CONFIGURATION                                                                                                         #
###################################################################################################################################################
MCP2_IP="0.0.0."
# save path on MCP2 where PSX saves will be downloaded from
MCP2_SAVE_PATH="/MemoryCards"
# local path where PSX saves will be downloaded to
MCP2_DOWNLOAD_LOCAL_PATH="$HOME/gamesaves/import/mcp2"
# local path where renamed PSX saves will be copied to
MCP2_RECONCILE_PATH="$HOME/gamesaves/reconciled/mcp2"
# local path where latest saves will be prepared for export back to MCP2
MCP2_EXPORT_PATH="$HOME/gamesaves/export/mcp2"
MCP2_USERNAME="username"
MCP2_PASSWORD="password"
###################################################################################################################################################
#             MiSTer CONFIGURATION                                                                                                                #
###################################################################################################################################################
MISTER_IP="0.0.0.0"
# save path on MiSTer where GBA saves will be downloaded from
MISTER_SAVE_PATH_GBA="/media/fat/saves/GBA"
# save path on MiSTer where N64 saves will be downloaded from
MISTER_SAVE_PATH_N64="/media/fat/saves/N64"
# save path on MiSTer where SNES saves will be downloaded from
MISTER_SAVE_PATH_SNES="/media/fat/saves/SNES"
# save path on MiSTer where PSX saves will be downloaded from
MISTER_SAVE_PATH_PSX="/media/fat/saves/PSX"
# local path where GBA saves will be downloaded to
MISTER_DOWNLOAD_LOCAL_PATH_GBA="$HOME/gamesaves/import/mister/gba"
# local path where N64 saves will be downloaded to
MISTER_DOWNLOAD_LOCAL_PATH_N64="$HOME/gamesaves/import/mister/n64"
# local path where SNES saves will be downloaded to
MISTER_DOWNLOAD_LOCAL_PATH_SNES="$HOME/gamesaves/import/mister/snes"
# local path where PSX saves will be downloaded to
MISTER_DOWNLOAD_LOCAL_PATH_PSX="$HOME/gamesaves/import/mister/psx"
# local path where GBA saves will be copied to
MISTER_RECONCILE_PATH_GBA="$HOME/gamesaves/reconciled/mister/gba"
# local path where N64 saves will be copied to
MISTER_RECONCILE_PATH_N64="$HOME/gamesaves/reconciled/mister/n64"
# local path where SNES saves will be copied to
MISTER_RECONCILE_PATH_SNES="$HOME/gamesaves/reconciled/mister/snes"
# local path where PSX saves will be copied to
MISTER_RECONCILE_PATH_PSX="$HOME/gamesaves/reconciled/mister/psx"
# local path where latest GBA saves will be prepared for export back to MISTER
MISTER_EXPORT_PATH_GBA="$HOME/gamesaves/export/mister/gba"
# local path where latest N64 saves will be prepared for export back to MISTER
MISTER_EXPORT_PATH_N64="$HOME/gamesaves/export/mister/n64"
# local path where latest SNES saves will be prepared for export back to MISTER
MISTER_EXPORT_PATH_SNES="$HOME/gamesaves/export/mister/snes"
# local path where latest PSX saves will be prepared for export back to MISTER
MISTER_EXPORT_PATH_PSX="$HOME/gamesaves/export/mister/psx"
#
MISTER_USERNAME="root"
MISTER_PASSWORD="1"
###################################################################################################################################################
#             NAS CONFIGURATION                                                                                                                   #
###################################################################################################################################################
NAS_IP="192.168.95.156"
# save path on NAS where GBA saves will be downloaded from
NAS_SAVE_PATH_GBA="/storage/Gaming/Saves/mGBA"
# save path on NAS where N64 saves will be downloaded from
NAS_SAVE_PATH_N64="/storage/Gaming/Saves/Mupen64Plus-Next"
# save path on NAS where SNES saves will be downloaded from
NAS_SAVE_PATH_SNES="/storage/Gaming/Saves/bsnes"
# save path on NAS where PSX saves will be downloaded from
NAS_SAVE_PATH_PSX="/storage/Gaming/Saves/Beetle PSX"
# local path where GBA saves will be downloaded to
NAS_DOWNLOAD_LOCAL_PATH_GBA="$HOME/gamesaves/import/nas/gba"
# local path where N64 saves will be downloaded to
NAS_DOWNLOAD_LOCAL_PATH_N64="$HOME/gamesaves/import/nas/n64"
# local path where SNES saves will be downloaded to
NAS_DOWNLOAD_LOCAL_PATH_SNES="$HOME/gamesaves/import/nas/snes"
# local path where PSX saves will be downloaded to
NAS_DOWNLOAD_LOCAL_PATH_PSX="$HOME/gamesaves/import/nas/psx"
# local path where GBA saves will be renamed and copied to
NAS_RECONCILE_PATH_GBA="$HOME/gamesaves/reconciled/nas/gba"
# local path where N64 saves will be renamed and copied to
NAS_RECONCILE_PATH_N64="$HOME/gamesaves/reconciled/nas/n64"
# local path where SNES saves will be renamed and copied to
NAS_RECONCILE_PATH_SNES="$HOME/gamesaves/reconciled/nas/snes"
# local path where PSX saves will be renamed and copied to
NAS_RECONCILE_PATH_PSX="$HOME/gamesaves/reconciled/nas/psx"
# local path where latest GBA saves will be prepared for export back to NAS
NAS_EXPORT_PATH_GBA="$HOME/gamesaves/export/nas/gba"
# local path where latest N64 saves will be prepared for export back to NAS
NAS_EXPORT_PATH_N64="$HOME/gamesaves/export/nas/n64"
# local path where latest SNES saves will be prepared for export back to NAS
NAS_EXPORT_PATH_SNES="$HOME/gamesaves/export/nas/snes"
# local path where latest PSX saves will be prepared for export back to NAS
NAS_EXPORT_PATH_PSX="$HOME/gamesaves/export/nas/psx"
NAS_USERNAME=bill
NAS_PASSWORD=Buttonwoods#1
###################################################################################################################################################
#             MASTER SAVE FILE DIRECTORIES                                                                                                        #
###################################################################################################################################################
MASTER_MAIN="$HOME/gamesaves/master"
# local path where the newest psx saves from all sources will be placed
MASTER_PSX="$HOME/gamesaves/master/psx"
# local path where the newest gba saves from all sources will be placed
MASTER_GBA="$HOME/gamesaves/master/gba"
# local path where the newest n64 saves from all sources will be placed
MASTER_N64="$HOME/gamesaves/master/n64"
# local path where the newest snes saves from all sources will be placed
MASTER_SNES="$HOME/gamesaves/master/snes"
###################################################################################################################################################
#             CHECK DEVICE ONLINE STATUS, PREPARE FTP BACKUP                                                                                      #
###################################################################################################################################################
backup_device_ftp () {
    local device_ip="$1"
    local save_path="$2"
    local local_path="$3"
    local username="$4"
    local password="$5"
    local device_name="$6"
    local include_pattern="$7"

    echo "Checking if $device_name is online..."
    ping -c 1 $device_ip &> /dev/null

    if [ $? -eq 0 ]; then
        echo "$device_name is online, starting backup..."
        local extra_opts=""
        # Check if device_name is "RetroArch" to enable passive mode
        if [[ "$device_name" == "NAS*" ]]; then
            extra_opts="set ftp:passive-mode true; "
        fi
        
        local include_cmd=""
        if [ ! -z "$include_pattern" ]; then
            include_cmd="--include '$include_pattern' "
        fi
        
        lftp -u "$username,$password" "$device_ip" -e "${extra_opts}mirror --verbose ${include_cmd}'$save_path' '$local_path'; quit"
        
        echo "Backup from $device_name completed."
    else
        echo "$device_name is not online."
    fi
}
###################################################################################################################################################
#             FTP BACKUP - MISTER                                                                                                                 #
###################################################################################################################################################
backup_device_ftp "$MISTER_IP" "$MISTER_SAVE_PATH_GBA" "$MISTER_DOWNLOAD_LOCAL_PATH_GBA" "$MISTER_USERNAME" "$MISTER_PASSWORD" "MiSTer FPGA GBA"
backup_device_ftp "$MISTER_IP" "$MISTER_SAVE_PATH_N64" "$MISTER_DOWNLOAD_LOCAL_PATH_N64" "$MISTER_USERNAME" "$MISTER_PASSWORD" "MiSTer FPGA N64"
backup_device_ftp "$MISTER_IP" "$MISTER_SAVE_PATH_SNES" "$MISTER_DOWNLOAD_LOCAL_PATH_SNES" "$MISTER_USERNAME" "$MISTER_PASSWORD" "MiSTer FPGA SNES"
backup_device_ftp "$MISTER_IP" "$MISTER_SAVE_PATH_PSX" "$MISTER_DOWNLOAD_LOCAL_PATH_PSX" "$MISTER_USERNAME" "$MISTER_PASSWORD" "MiSTer FPGA PSX"
###################################################################################################################################################
#             FTP BACKUP - MCP1                                                                                                                   #
###################################################################################################################################################
backup_device_ftp "$MCP1_IP" "$MCP1_SAVE_PATH" "$MCP1_DOWNLOAD_LOCAL_PATH" "$MCP1_USERNAME" "$MCP1_PASSWORD" "Memcard Pro 1" "-1\.mcd$"
echo "Setting permissions for MCP1 downloads..."
find "$MCP1_DOWNLOAD_LOCAL_PATH" -type d -exec chmod 775 {} \;
find "$MCP1_DOWNLOAD_LOCAL_PATH" -type f -exec chmod 664 {} \;
echo "Permissions set for MCP1 downloads."
###################################################################################################################################################
#             FTP BACKUP - MCP2                                                                                                                   #
###################################################################################################################################################
backup_device_ftp "$MCP2_IP" "$MCP2_SAVE_PATH" "$MCP2_DOWNLOAD_LOCAL_PATH" "$MCP2_USERNAME" "$MCP2_PASSWORD" "Memcard Pro 2" "-1\.mcd$"
echo "Setting permissions for MCP2 downloads..."
find "$MCP2_DOWNLOAD_LOCAL_PATH" -type d -exec chmod 775 {} \;
find "$MCP2_DOWNLOAD_LOCAL_PATH" -type f -exec chmod 664 {} \;
echo "Permissions set for MCP2 downloads."
###################################################################################################################################################
#             FTP BACKUP - NAS (RETROARCH SAVE FILES)                                                                                             #
###################################################################################################################################################
backup_device_ftp "$NAS_IP" "$NAS_SAVE_PATH_GBA" "$NAS_DOWNLOAD_LOCAL_PATH_GBA" "$NAS_USERNAME" "$NAS_PASSWORD" "NAS (GBA)"
backup_device_ftp "$NAS_IP" "$NAS_SAVE_PATH_N64" "$NAS_DOWNLOAD_LOCAL_PATH_N64" "$NAS_USERNAME" "$NAS_PASSWORD" "NAS (N64)"
backup_device_ftp "$NAS_IP" "$NAS_SAVE_PATH_SNES" "$NAS_DOWNLOAD_LOCAL_PATH_SNES" "$NAS_USERNAME" "$NAS_PASSWORD" "NAS (SNES)"
backup_device_ftp "$NAS_IP" "$NAS_SAVE_PATH_PSX" "$NAS_DOWNLOAD_LOCAL_PATH_PSX" "$NAS_USERNAME" "$NAS_PASSWORD" "NAS (PSX)"
###################################################################################################################################################
echo "Loading in the CSV for PSX GameID mapping, this could take a minute or two."
###################################################################################################################################################
#             LOAD IN CSV FOR GAMEID MAPPING OF PSX TITLES                                                                                        #
###################################################################################################################################################
declare -A gameid_to_title_map
while IFS=, read -r id title; do
    # Remove carriage return from the title if present
    title=$(echo "$title" | tr -d '\r')
    # Replace '\'' (escaped apostrophe) with "'" (actual apostrophe)
    title=$(echo "$title" | sed 's/\\"//g')
    gameid_to_title_map["$id"]="$title"
done < "$CSV_FILE"
###################################################################################################################################################
#             COPY AND RENAME .MCD FILES MEMCARD PRO 1                                                                                            #
###################################################################################################################################################
copy_and_rename_mcp1 () {
    local source_path="$MCP1_DOWNLOAD_LOCAL_PATH"
    local target_path="$MCP1_RECONCILE_PATH"
    echo "Searching for .mcd files in $source_path..."

    find "$source_path" -type f -name "*.mcd" | while read -r file_path; do
        file_name=$(basename "$file_path")
        game_id="${file_name%-1.mcd}"
        if [[ "$file_name" == *"PSXMAINEXE"* ]] || [[ "$file_name" == *"MemoryCard"* ]]; then
            echo "Skipping file: $file_name"
            continue
        fi
        if [ "${gameid_to_title_map[$game_id]}" ]; then
            new_file_name="${gameid_to_title_map[$game_id]}.sav"
            cp -P "$file_path" "$target_path/$new_file_name"
            echo "Copied and renamed $file_name to $new_file_name"
        else
            echo "GameID $game_id not found in CSV, copying without renaming."
            cp -P "$file_path" "$target_path/$file_name"
        fi
    done
    echo "Copy and renaming of .mcd files completed."
}

copy_and_rename_mcp1 "$MCP1_DOWNLOAD_LOCAL_PATH"
###################################################################################################################################################
#             COPY AND RENAME .MCD FILES MEMCARD PRO 2                                                                                            #
###################################################################################################################################################
copy_and_rename_mcp2 () {
    local source_path="$MCP2_DOWNLOAD_LOCAL_PATH"
    local target_path="$MCP2_REONCILE_PATH"
    echo "Searching for .mcd files in $source_path..."

    find "$source_path" -type f -name "*.mcd" | while read -r file_path; do
        file_name=$(basename "$file_path")
        game_id="${file_name%-1.mcd}"
        if [[ "$file_name" == *"PSXMAINEXE"* ]] || [[ "$file_name" == *"MemoryCard"* ]]; then
            echo "Skipping file: $file_name"
            continue
        fi
        if [ "${gameid_to_title_map[$game_id]}" ]; then
            new_file_name="${gameid_to_title_map[$game_id]}.sav"
            cp -P "$file_path" "$target_path/$new_file_name"
            echo "Copied and renamed $file_name to $new_file_name"
        else
            echo "GameID $game_id not found in CSV, copying without renaming."
            cp -P "$file_path" "$target_path/$file_name"
        fi
    done
    echo "Copy and renaming of .mcd files completed."
}

copy_and_rename_mcp2 "$MCP2_DOWNLOAD_LOCAL_PATH"
###################################################################################################################################################
#             COPY MISTER SAVES (NO RENAME NEEDED)                                                                                                #
###################################################################################################################################################
copy_mister_saves () {
    local source_path="$1"
    local target_path="$2"
    echo "Copying saves from MiSTer..."
    find "$source_path" -type f -exec cp --preserve=timestamps {} "$target_path" \;
    echo "Copy of MiSTer saves completed."
}

# Define arrays for source and target paths
source_paths=("$MISTER_DOWNLOAD_LOCAL_PATH_GBA" "$MISTER_DOWNLOAD_LOCAL_PATH_N64" "$MISTER_DOWNLOAD_LOCAL_PATH_SNES" "$MISTER_DOWNLOAD_LOCAL_PATH_PSX")
target_paths=("$MISTER_RECONCILE_PATH_GBA" "$MISTER_RECONCILE_PATH_N64" "$MISTER_RECONCILE_PATH_SNES" "$MISTER_RECONCILE_PATH_PSX")

# Iterate over the arrays and call the function for each pair
for i in "${!source_paths[@]}"; do
    copy_mister_saves "${source_paths[$i]}" "${target_paths[$i]}"
done

###################################################################################################################################################
#             COPY AND RENAME NAS SAVES (.SRM/RETROARCH FORMAT)                                                                                   #
###################################################################################################################################################
copy_and_rename_nas_saves () {
    local source_path="$1"
    local target_path="$2"
    echo "Copying and renaming saves from $source_path to $target_path..."
    find "$source_path" -type f -name "*.srm" | while read -r file_path; do
        file_name=$(basename "$file_path" .srm)
        cp --preserve=timestamps "$file_path" "$target_path/${file_name}.sav"
    done
    echo "Copy and renaming of saves completed."
}

# Define arrays for source and target paths
source_paths=("$NAS_DOWNLOAD_LOCAL_PATH_GBA" "$NAS_DOWNLOAD_LOCAL_PATH_N64" "$NAS_DOWNLOAD_LOCAL_PATH_SNES" "$NAS_DOWNLOAD_LOCAL_PATH_PSX")
target_paths=("$NAS_RECONCILE_PATH_GBA" "$NAS_RECONCILE_PATH_N64" "$NAS_RECONCILE_PATH_SNES" "$NAS_RECONCILE_PATH_PSX")

# Iterate over the arrays and call the function for each pair
for i in "${!source_paths[@]}"; do
    copy_and_rename_nas_saves "${source_paths[$i]}" "${target_paths[$i]}"
done
###################################################################################################################################################
#             COMPARE GBA SAVES ACROSS DIRECTORIES AND COPY MOST RECENT SAVE TO MASTER                                                            #
###################################################################################################################################################
compare_and_export_gba_saves () {
    local master_export_path="$MASTER_GBA"

    declare -A latest_file_paths

    local compare_paths=(
        "$MISTER_RECONCILE_PATH_GBA"
        "$NAS_RECONCILE_PATH_GBA"
    )

    echo "Starting comparison and copying process(GBA)..."

    # Loop over each directory
    for path in "${compare_paths[@]}"; do
        echo "Processing directory: $path"
        # List files in current directory
        while IFS= read -r -d '' file; do
            file_name=$(basename "$file")
            echo "Found file: $file_name in $path"
            # Check if this file is either not in the array or is newer than the one in the array
            if [[ ! -v latest_file_paths["$file_name"] ]] || [[ "$file" -nt "${latest_file_paths["$file_name"]}" ]]; then
                latest_file_paths["$file_name"]=$file
                echo "Updated latest file for $file_name to $file"
            fi
        done < <(find "$path" -type f -print0)
    done

    echo "Finished comparing GBA saves, copying to $master_export_path..."

    # Copy the identified files to the master directory
    for file in "${latest_file_paths[@]}"; do
        if [[ -n "$file" ]]; then
            echo "Copying $(basename "$file") to $master_export_path"
            cp -p "$file" "$master_export_path/"
        fi
    done

    echo "Copy GBA saves to master directory completed."
}

compare_and_export_gba_saves
###################################################################################################################################################
#             COMPARE N64 SAVES ACROSS DIRECTORIES AND COPY MOST RECENT SAVE TO MASTER                                                            #
###################################################################################################################################################
compare_and_export_n64_saves () {
    local master_export_path="$MASTER_N64"

    declare -A latest_file_paths

    local compare_paths=(
        "$MISTER_RECONCILE_PATH_N64"
        "$NAS_RECONCILE_PATH_N64"
    )

    echo "Starting comparison and copying process(N64)..."

    # Loop over each directory
    for path in "${compare_paths[@]}"; do
        echo "Processing directory: $path"
        # List files in current directory
        while IFS= read -r -d '' file; do
            file_name=$(basename "$file")
            echo "Found file: $file_name in $path"
            # Check if this file is either not in the array or is newer than the one in the array
            if [[ ! -v latest_file_paths["$file_name"] ]] || [[ "$file" -nt "${latest_file_paths["$file_name"]}" ]]; then
                latest_file_paths["$file_name"]=$file
                echo "Updated latest file for $file_name to $file"
            fi
        done < <(find "$path" -type f -print0)
    done

    echo "Finished comparing N64 saves, copying to $master_export_path..."

    # Copy the identified files to the master directory
    for file in "${latest_file_paths[@]}"; do
        if [[ -n "$file" ]]; then
            echo "Copying $(basename "$file") to $master_export_path"
            cp -p "$file" "$master_export_path/"
        fi
    done

    echo "Copy N64 saves to master directory completed."
}

compare_and_export_n64_saves
###################################################################################################################################################
#             COMPARE SNES SAVES ACROSS DIRECTORIES AND COPY MOST RECENT SAVE TO MASTER                                                            #
###################################################################################################################################################
compare_and_export_snes_saves () {
    local master_export_path="$MASTER_SNES"

    declare -A latest_file_paths

    local compare_paths=(
        "$MISTER_RECONCILE_PATH_SNES"
        "$NAS_RECONCILE_PATH_SNES"
    )

    echo "Starting comparison and copying process(SNES)..."

    # Loop over each directory
    for path in "${compare_paths[@]}"; do
        echo "Processing directory: $path"
        # List files in current directory
        while IFS= read -r -d '' file; do
            file_name=$(basename "$file")
            echo "Found file: $file_name in $path"
            # Check if this file is either not in the array or is newer than the one in the array
            if [[ ! -v latest_file_paths["$file_name"] ]] || [[ "$file" -nt "${latest_file_paths["$file_name"]}" ]]; then
                latest_file_paths["$file_name"]=$file
                echo "Updated latest file for $file_name to $file"
            fi
        done < <(find "$path" -type f -print0)
    done

    echo "Finished comparing SNES saves, copying to $master_export_path..."

    # Copy the identified files to the master directory
    for file in "${latest_file_paths[@]}"; do
        if [[ -n "$file" ]]; then
            echo "Copying $(basename "$file") to $master_export_path"
            cp -p "$file" "$master_export_path/"
        fi
    done

    echo "Copy SNES saves to master directory completed."
}

compare_and_export_snes_saves
###################################################################################################################################################
#             COMPARE PSX SAVES ACROSS DIRECTORIES AND COPY MOST RECENT SAVE TO MASTER                                                            #
###################################################################################################################################################
compare_and_export_psx_saves () {
    local master_export_path="$MASTER_PSX"

    declare -A latest_file_paths

    local compare_paths=(
        "$MISTER_RECONCILE_PATH_PSX"
        "$NAS_RECONCILE_PATH_PSX"
        "$MCP1_RECONCILE_PATH"
        "$MCP2_RECONCILE_PATH"
    )

    echo "Starting comparison and copying process(PSX)..."

    # Loop over each directory
    for path in "${compare_paths[@]}"; do
        echo "Processing directory: $path"
        # List files in current directory
        while IFS= read -r -d '' file; do
            file_name=$(basename "$file")
            echo "Found file: $file_name in $path"
            # Check if this file is either not in the array or is newer than the one in the array
            if [[ ! -v latest_file_paths["$file_name"] ]] || [[ "$file" -nt "${latest_file_paths["$file_name"]}" ]]; then
                latest_file_paths["$file_name"]=$file
                echo "Updated latest file for $file_name to $file"
            fi
        done < <(find "$path" -type f -print0)
    done

    echo "Finished comparing PSX saves, copying to $master_export_path..."

    # Copy the identified files to the master directory
    for file in "${latest_file_paths[@]}"; do
        if [[ -n "$file" ]]; then
            echo "Copying $(basename "$file") to $master_export_path"
            cp -p "$file" "$master_export_path/"
        fi
    done

    echo "Copy PSX saves to master directory completed."
}

compare_and_export_psx_saves
###################################################################################################################################################
#             PREPARE MASTER SAVE LIST FOR MISTER EXPORT                                                                                          #
###################################################################################################################################################
# Copy saves for MiSTer
cp -p "$MASTER_GBA"/* "$MISTER_EXPORT_PATH_GBA"
cp -p "$MASTER_N64"/* "$MISTER_EXPORT_PATH_N64"
cp -p "$MASTER_SNES"/* "$MISTER_EXPORT_PATH_SNES"
cp -p "$MASTER_PSX"/* "$MISTER_EXPORT_PATH_PSX"

# Copy and rename saves for NAS
for file in "$MASTER_GBA"/*.sav; do
  filename=$(basename -- "$file")
  base_name="${filename%.*}"
  cp -p "$file" "$NAS_EXPORT_PATH_GBA/$base_name.srm"
done

for file in "$MASTER_N64"/*.sav; do
  filename=$(basename -- "$file")
  base_name="${filename%.*}"
  cp -p "$file" "$NAS_EXPORT_PATH_N64/$base_name.srm"
done

for file in "$MASTER_SNES"/*.sav; do
  filename=$(basename -- "$file")
  base_name="${filename%.*}"
  cp -p "$file" "$NAS_EXPORT_PATH_SNES/$base_name.srm"
done

for file in "$MASTER_PSX"/*.sav; do
  filename=$(basename -- "$file")
  base_name="${filename%.*}"
  cp -p "$file" "$NAS_EXPORT_PATH_PSX/$base_name.srm"
done

# Read CSV and prepare an associative array for game titles to GameIDs
declare -A title_game_id_map
while IFS=, read -r game_id title; do
  # Remove potential leading/trailing spaces in title
  title=$(echo "$title" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  title_game_id_map["$title"]="$game_id"
done < "$CSV_FILE"

# Copy and rename saves for MemCard Pro 1
for file in "$MASTER_PSX"/*.sav; do
  filename=$(basename -- "$file")
  base_name="${filename%.*}"
  game_id="${title_game_id_map["$base_name"]}"
  if [[ -n "$game_id" ]]; then
    game_id=$(echo "$game_id" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    gameid_folder="$MCP1_EXPORT_PATH/$game_id"
    mkdir -p "$gameid_folder"
    cp -p "$file" "$gameid_folder/$game_id-1.mcd"
  else
    echo "Warning: No gameID found for '$base_name'. File not copied for gameID renaming."
  fi
done

# Copy and rename saves for MemCard Pro 2
for file in "$MASTER_PSX"/*.sav; do
  filename=$(basename -- "$file")
  base_name="${filename%.*}"
  game_id="${title_game_id_map["$base_name"]}"
  if [[ -n "$game_id" ]]; then
    game_id=$(echo "$game_id" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    gameid_folder="$MCP2_EXPORT_PATH/$game_id"
    mkdir -p "$gameid_folder"
    cp -p "$file" "$gameid_folder/$game_id-1.mcd"
  else
    echo "Warning: No gameID found for '$base_name'. File not copied for gameID renaming."
  fi
done

echo "Copy and rename of save files completed."
###################################################################################################################################################
#             EXPORT LATEST SAVE FILES BACK TO MEMCARD PRO 1                                                                                      #
###################################################################################################################################################
is_online() {
    ping -c 1 $1 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "1"
    else
        echo "0"
    fi
}

# Check if device is online
if [ $(is_online "$MCP1_IP") -eq 1 ]; then
    echo "MemCard Pro 1 ($MCP1_IP) is online. Proceeding with FTP..."
    lftp -e "
    open $MCP1_IP
    user $MCP1_USERNAME $MCP1_PASSWORD
    lcd $MCP1_EXPORT_PATH
    mirror --reverse --verbose --no-perms --no-umask $MCP1_EXPORT_PATH $MCP1_SAVE_PATH
    bye
    "
else
    echo "MemCard Pro 1 ($MCP1_IP) is not reachable. Skipping..."
fi
###################################################################################################################################################
#             EXPORT LATEST SAVE FILES BACK TO MEMCARD PRO 2                                                                                      #
###################################################################################################################################################
is_online() {
    ping -c 1 $1 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "1"
    else
        echo "0"
    fi
}

# Check if device is online
if [ $(is_online "$MCP2_IP") -eq 1 ]; then
    echo "MemCard Pro 2 ($MCP2_IP) is online. Proceeding with FTP..."
    lftp -e "
    open $MCP2_IP
    user $MCP2_USERNAME $MCP1_PASSWORD
    lcd $MCP2_EXPORT_PATH
    mirror --reverse --verbose --no-perms --no-umask $MCP2_EXPORT_PATH $MCP2_SAVE_PATH
    bye
    "
else
    echo "MemCard Pro 2 ($MCP2_IP) is not reachable. Skipping..."
fi
###################################################################################################################################################
#             EXPORT LATEST SAVE FILES BACK TO NAS                                                                                                #
###################################################################################################################################################
# Define arrays for each path type
nas_export_paths=("$NAS_EXPORT_PATH_GBA" "$NAS_EXPORT_PATH_N64" "$NAS_EXPORT_PATH_SNES" "$NAS_EXPORT_PATH_PSX")
nas_save_paths=("$NAS_SAVE_PATH_GBA" "$NAS_SAVE_PATH_N64" "$NAS_SAVE_PATH_SNES" "$NAS_SAVE_PATH_PSX")

is_online() {
    ping -c 1 $1 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "1"
    else
        echo "0"
    fi
}

# Check if device is online
if [ $(is_online "$NAS_IP") -eq 1 ]; then
    echo "NAS ($NAS_IP) is online. Proceeding with FTP..."
    for i in "${!nas_export_paths[@]}"; do
    lftp -e "
    open $NAS_IP
    user $NAS_USERNAME $NAS_PASSWORD
    lcd ${nas_export_paths[$i]}
    mirror --reverse --verbose --no-perms --no-umask "${nas_export_paths[$i]}" "${nas_save_paths[$i]}"
    bye
    "
    done
else
    echo "NAS($NAS_IP) is not reachable. Skipping..."
fi
###################################################################################################################################################
#             EXPORT LATEST SAVE FILES BACK TO MISTER                                                                                             #
###################################################################################################################################################
# Define arrays for export and save paths
mister_export_paths=("$MISTER_EXPORT_PATH_GBA" "$MISTER_EXPORT_PATH_N64" "$MISTER_EXPORT_PATH_SNES" "$MISTER_EXPORT_PATH_PSX")
mister_save_paths=("$MISTER_SAVE_PATH_GBA" "$MISTER_SAVE_PATH_N64" "$MISTER_SAVE_PATH_SNES" "$MISTER_SAVE_PATH_PSX")

is_online() {
    ping -c 1 $1 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "1"
    else
        echo "0"
    fi
}

# Check if device is online
if [ $(is_online "$MISTER_IP") -eq 1 ]; then
    echo "MiSTer ($MISTER_IP) is online. Proceeding with FTP..."
    for i in "${!mister_export_paths[@]}"; do
    lftp -e "
    open $MISTER_IP
    user $MISTER_USERNAME $MISTER_PASSWORD
    lcd ${mister_export_paths[$i]}
    mirror --reverse --verbose --no-perms --no-umask ${mister_export_paths[$i]} ${mister_save_paths[$i]}
    bye
    "
    done
else
    echo "MiSTer($MISTER_IP) is not reachable. Skipping..."
fi
###################################################################################################################################################
#             END                                                                                                                                 #
###################################################################################################################################################
echo "Script has reached the end."
###################################################################################################################################################
#             THANKS    @niemasd - I used their PSX GameID JSON data for creating the CSV for PSX GameID to Game Title mapping                    #
###################################################################################################################################################
