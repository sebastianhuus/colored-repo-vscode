vscode_folder=".vscode"
settings_file="$vscode_folder/Settings.json"

add_profile() {
    echo $profile_string >> $settings_file
}

init() {
    mkdir .vscode
    touch $settings_file
}

init