#!/bin/bash
###################################################################################################################################################
#             CREATE + VALIDATE LOCAL DIRECTORY STRUCTURE                                                                                         #
###################################################################################################################################################
# list of directories to be validated or created for script execution
directories=(
#import directory is where all raw save files will be downloaded to
    $HOME/gamesaves/import
    $HOME/gamesaves/import/mcp1
    $HOME/gamesaves/import/mister/psx
#saves from 'import' will be renamed for consistency/comparison and placed into 'reconciled'
    $HOME/gamesaves/reconciled
    $HOME/gamesaves/reconciled/mcp1
    $HOME/gamesaves/reconciled/mister/psx
#saves from 'reconciled' will be compared with the newest save for each game/platform placed in 'master' to create a 'master list' of saves
    $HOME/gamesaves/master
    $HOME/gamesaves/master/psx
#saves from 'master' will be renamed appropriately for each device/platform type and copied to 'export'. These are the saves that will be uploaded back to each device.
    $HOME/gamesaves/export
    $HOME/gamesaves/export/mcp1
    $HOME/gamesaves/export/mister/psx
#'system' is where files needed for script execution (such as CSVs) will be placed
    $HOME/gamesaves/system
)

for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "Creating directory: $dir"
        mkdir -p "$dir"
    else
        echo "Directory already exists: $dir"
    fi
done
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
#             DEVICE CONFIGURATION                                                                                                                #
###################################################################################################################################################
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
MCP1_USERNAME="notmadcatz"
MCP1_PASSWORD="notmadcatz"
###################################################################################################################################################
#             MiSTer CONFIGURATION                                                                                                                #
###################################################################################################################################################
MISTER_IP="0.0.0.0"
# save path on MiSTer where PSX saves will be downloaded from
MISTER_SAVE_PATH_PSX="/media/fat/saves/PSX"
# local path where PSX saves will be downloaded to
MISTER_DOWNLOAD_LOCAL_PATH_PSX="$HOME/gamesaves/import/mister/psx"
# local path where PSX saves will be copied to
MISTER_RECONCILE_PATH_PSX="$HOME/gamesaves/reconciled/mister/psx"
# local path where latest PSX saves will be prepared for export back to MISTER
MISTER_EXPORT_PATH_PSX="$HOME/gamesaves/export/mister/psx"
MISTER_USERNAME="root"
MISTER_PASSWORD="1"
###################################################################################################################################################
#             MASTER SAVE FILE DIRECTORIES                                                                                                        #
###################################################################################################################################################
MASTER_MAIN="$HOME/gamesaves/master"
# local path where the newest psx saves from all sources will be placed
MASTER_PSX="$HOME/gamesaves/master/psx"
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

        local include_cmd=""
        if [ ! -z "$include_pattern" ]; then
            include_cmd="--include '$include_pattern' "
        fi
        
        lftp -u "$username,$password" "$device_ip" -e "mirror --verbose ${include_cmd}'$save_path' '$local_path'; quit"
        
        echo "Backup from $device_name completed."
    else
        echo "$device_name is not online."
    fi
}
###################################################################################################################################################
#             FTP BACKUP - MISTER                                                                                                                 #
###################################################################################################################################################
backup_device_ftp "$MISTER_IP" "$MISTER_SAVE_PATH_PSX" "$MISTER_DOWNLOAD_LOCAL_PATH_PSX" "$MISTER_USERNAME" "$MISTER_PASSWORD" "MiSTer FPGA PSX"
###################################################################################################################################################
#             FTP BACKUP - MCP1                                                                                                                   #
###################################################################################################################################################
backup_device_ftp "$MCP1_IP" "$MCP1_SAVE_PATH" "$MCP1_DOWNLOAD_LOCAL_PATH" "$MCP1_USERNAME" "$MCP1_PASSWORD" "Memcard Pro 1" "-1\.mcd$"
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
            cp -p "$file_path" "$target_path/$new_file_name"
            echo "Copied and renamed $file_name to $new_file_name"
        else
            echo "GameID $game_id not found in CSV, copying without renaming."
            cp -p "$file_path" "$target_path/$file_name"
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
#             COMPARE PSX SAVES ACROSS DIRECTORIES AND COPY MOST RECENT SAVE TO MASTER                                                            #
###################################################################################################################################################
compare_and_export_psx_saves () {
    local master_export_path="$MASTER_PSX"

    declare -A latest_file_paths

    local compare_paths=(
        "$MISTER_RECONCILE_PATH_PSX"
        "$MCP1_RECONCILE_PATH"
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
echo "Preparing PSX saves for export to MiSTer/MCP, this could take a minute or two."
# Copy saves for MiSTer
cp -p "$MASTER_PSX"/* "$MISTER_EXPORT_PATH_PSX"

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

# Usage within your script
# Define your device IP or hostname
device_ip="$MCP1_IP"

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
#             EXPORT LATEST SAVE FILES BACK TO MISTER                                                                                             #
###################################################################################################################################################
# Define arrays for export and save paths
mister_export_paths=("$MISTER_EXPORT_PATH_PSX")
mister_save_paths=("$MISTER_SAVE_PATH_PSX")

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
    echo "MiSTer ($MISTER_IP) is not reachable. Skipping..."
fi
###################################################################################################################################################
#             END                                                                                                                                 #
###################################################################################################################################################
echo "Script has reached the end."
###################################################################################################################################################
#             THANKS    @niemasd - I used their PSX GameID JSON data for creating the CSV for PSX GameID to Game Title mapping                    #
###################################################################################################################################################
