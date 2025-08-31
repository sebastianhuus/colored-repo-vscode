vscode_folder=".vscode"
settings_file="$vscode_folder/Settings.json"
PROFILES_FILE="$HOME/.colored-repo-profiles"

init_profiles() {
    if [[ -f "$PROFILES_FILE" ]]; then
        echo "Profiles file already einit() {
    mkdir -p .vscode
    touch $settings_file
    
    # Create .git/info/exclude if .git directory exists
    if [[ -d ".git" ]]; then
        mkdir -p .git/info
        local exclude_file=".git/info/exclude"
        
        # Check if settings exclusion already exists
        if [[ -f "$exclude_file" ]] && grep -q "\.vscode/[Ss]ettings\.json" "$exclude_file"; then
            echo "VS Code settings already excluded in $exclude_file"
        else
            echo "" >> "$exclude_file"
            echo "# VS Code workspace settings (added by colored-repo)" >> "$exclude_file"
            echo ".vscode/Settings.json" >> "$exclude_file"
            echo ".vscode/settings.json" >> "$exclude_file"
            echo "Added VS Code settings exclusion to $exclude_file"
        fi
    else
        echo "Warning: Not a git repository. Skipping .git/info/exclude setup."
    fi
}s at $PROFILES_FILE"
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
    echo "add_profile function not yet implemented"
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
    echo "  colored-repo install             # Install colored-repo globally (symlink to /usr/local/bin)"
    echo "  colored-repo help                # Show this help message"
    echo ""
    echo "Available profiles are defined in ~/.colored-repo-profiles"
    echo "Colors are applied to the current VS Code workspace (.vscode/settings.json)"
}

# list all the saved profiles from computer. use ~/.colored-repo-profiles
list_profiles() {
    if [[ ! -f "$PROFILES_FILE" ]]; then
        echo "No profiles file found at $PROFILES_FILE"
        echo "Run 'colored-repo init-profiles' to create one"
        return 1
    fi
    
    # Extract profile names from INI file (lines starting with [profile-name])
    grep '^\[' "$PROFILES_FILE" | sed 's/^\[\(.*\)\]$/\1/'
}

set_profile() {
    # sets the profile of current repo to some existing profiles
    # should use gum select or gum filter
    
    if [[ ! -f "$PROFILES_FILE" ]]; then
        echo "No profiles file found at $PROFILES_FILE"
        echo "Run 'colored-repo init-profiles' to create one"
        return 1
    fi
    
    local profile_name="$1"
    
    # If no profile name provided, use gum filter for interactive selection
    if [[ -z "$profile_name" ]]; then
        profile_name=$(list_profiles | gum filter \
            --header="Select a color profile:" \
            --placeholder="Type to filter profiles..." \
            --prompt="❯ " \
            --select-if-one)
        
        # Check if user cancelled selection
        if [[ -z "$profile_name" ]]; then
            echo "No profile selected"
            return 1
        fi
    fi
    
    # Validate profile exists
    if ! grep -q "^\[$profile_name\]" "$PROFILES_FILE"; then
        echo "Profile '$profile_name' not found"
        echo "Available profiles:"
        list_profiles
        return 1
    fi
    
    # Extract colors from profile
    local foreground=$(awk -v profile="$profile_name" '
        /^\[.*\]/ { current_section = substr($0, 2, length($0)-2) }
        current_section == profile && /^foregroundcolor/ { 
            gsub(/^[^=]*=[ \t]*/, ""); 
            gsub(/[ \t]*$/, ""); 
            gsub(/"/, "");
            print; 
            exit 
        }
    ' "$PROFILES_FILE")
    
    local background=$(awk -v profile="$profile_name" '
        /^\[.*\]/ { current_section = substr($0, 2, length($0)-2) }
        current_section == profile && /^backgroundcolor/ { 
            gsub(/^[^=]*=[ \t]*/, ""); 
            gsub(/[ \t]*$/, ""); 
            gsub(/"/, "");
            print; 
            exit 
        }
    ' "$PROFILES_FILE")
    
    if [[ -z "$foreground" || -z "$background" ]]; then
        echo "Error: Profile '$profile_name' is missing color values"
        return 1
    fi
    
    # Create .vscode directory if it doesn't exist
    mkdir -p "$vscode_folder"
    
    # Create or update settings.json with workbench colors
    cat > "$settings_file" << EOF
{
    "workbench.colorCustomizations": {
        "titleBar.activeBackground": "$background",
        "titleBar.activeForeground": "$foreground",
        "titleBar.inactiveBackground": "$background",
        "titleBar.inactiveForeground": "$foreground"
    }
}
EOF
    
    echo "Applied profile '$profile_name' to current workspace"
    echo "Foreground: $foreground"
    echo "Background: $background"
}

show_current() {
    echo "show_current function not yet implemented"
}

install() {
    local script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    local bin_path="/usr/local/bin/colored-repo"
    
    # Check if /usr/local/bin exists
    if [[ ! -d "/usr/local/bin" ]]; then
        echo "Error: /usr/local/bin directory does not exist"
        echo "You may need to create it with: sudo mkdir -p /usr/local/bin"
        return 1
    fi
    
    # Check if symlink already exists
    if [[ -L "$bin_path" ]]; then
        echo "Symlink already exists at $bin_path"
        echo "Current target: $(readlink "$bin_path")"
        read -q "REPLY?Replace existing symlink? (y/n): "
        echo
        if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
            echo "Installation cancelled"
            return 1
        fi
        sudo rm "$bin_path"
    elif [[ -f "$bin_path" ]]; then
        echo "Error: File already exists at $bin_path (not a symlink)"
        echo "Please remove it manually and try again"
        return 1
    fi
    
    # Create symlink
    if sudo ln -s "$script_path" "$bin_path"; then
        echo "✅ Successfully installed colored-repo to $bin_path"
        echo "You can now use 'colored-repo' from anywhere!"
        echo ""
        echo "Try: colored-repo help"
    else
        echo "❌ Failed to create symlink. Check permissions."
        return 1
    fi
}

init() {
    mkdir .vscode
    touch $settings_file
}

# Argument handler
case "$1" in
    "init-profiles"|"init")
        init_profiles
        ;;
    "list"|"ls")
        list_profiles
        ;;
    "set")
        set_profile "$2"
        ;;
    "add")
        if [[ -z "$2" ]]; then
            echo "Error: Profile name required"
            echo "Usage: colored-repo add <profile-name>"
            exit 1
        fi
        add_profile "$2" "$3" "$4"
        ;;
    "current"|"show")
        show_current
        ;;
    "edit")
        ${EDITOR:-nano} "$PROFILES_FILE"
        ;;
    "install")
        install
        ;;
    "help"|"-h"|"--help"|"")
        show_help
        ;;
    *)
        if [[ -n "$1" ]]; then
            echo "Unknown command: $1"
        fi
        show_help
        exit 1
        ;;
esac