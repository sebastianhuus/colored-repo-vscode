vscode_folder=".vscode"
settings_file="$vscode_folder/Settings.json"
PROFILES_FILE="$HOME/.colored-repo-profiles"

init_profiles() {
    if [[ -f "$PROFILES_FILE" ]]; then
        echo "Profiles file already exists at $PROFILES_FILE"
        echo "Use your editor to modify it"
        return 1
    fi
    
    cat > "$PROFILES_FILE" << 'EOF'
# Colored Repo Profile Configuration File
# 
# Define your color profiles in INI format:
# [profile-name]
# foregroundcolor = "#hexcolor"
# backgroundcolor = "#hexcolor"
#
# Example profiles:

[dark-blue]
foregroundcolor = "#ffffff"
backgroundcolor = "#1e3a8a"

[green-theme]
foregroundcolor = "#000000"
backgroundcolor = "#22c55e"

[purple-mood]
foregroundcolor = "#ffffff"
backgroundcolor = "#7c3aed"

[orange-energy]
foregroundcolor = "#000000"
backgroundcolor = "#ea580c"

# Add more profiles as needed
EOF
    
    echo "Created profiles file at $PROFILES_FILE"
    echo "Edit the file to add your actual color profiles"
}

add_profile() {
    # add profile to local config on computer and save it
    # needs a name, foreground color, background color
    # [name]
    # foregroundcolor = x
    # backgroundcolor = y
}

show_help() {
    echo "Colored Repo - VS Code Workspace Color Profile Manager"
    echo ""
    echo "Usage:"
    echo "  colored-repo init-profiles       # Initialize profiles file with examples"
    echo "  colored-repo list                # Show available color profiles"
    echo "  colored-repo set                 # Interactive profile selection with gum"
    echo "  colored-repo add <name>          # Add a new color profile"
    echo "  colored-repo current             # Show current workspace colors"
    echo "  colored-repo edit                # Edit profiles file"
    echo "  colored-repo help                # Show this help message"
    echo ""
    echo "Available profiles are defined in ~/.colored-repo-profiles"
    echo "Colors are applied to the current VS Code workspace (.vscode/settings.json)"
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