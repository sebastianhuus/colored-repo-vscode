vscode_folder=".vscode"
settings_file="$vscode_folder/Settings.json"

add_profile() {
    # add profile to local config on computer and save it
    # needs a name, foreground color, background color
    # [name]
    # foregroundcolor = x
    # backgroundcolor = y
}

# list all the saved profiles from computer. use ~/.colored-repo-profiles
list_profiles() {

}

set_profile() {
    # sets the profile of current repo to some existing profiles
    # should use gum select or gum filter
}

init() {
    mkdir .vscode
    touch $settings_file
}

init