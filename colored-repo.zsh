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

init() {
    mkdir -p .vscode
    touch $settings_file
}

hsl_to_hex() {
    local h=$1 s=$2 l=$3
    
    # Normalize inputs
    h=$(echo "scale=6; $h / 360" | bc -l)
    s=$(echo "scale=6; $s / 100" | bc -l)
    l=$(echo "scale=6; $l / 100" | bc -l)
    
    # HSL to RGB conversion
    local c=$(echo "scale=6; (1 - sqrt(($l * 2 - 1)^2)) * $s" | bc -l)
    local x=$(echo "scale=6; $c * (1 - sqrt(($h * 6 - 2 * ($h * 6 / 2))^2))" | bc -l)
    local m=$(echo "scale=6; $l - $c / 2" | bc -l)
    
    local r g b
    local h_sector=$(echo "scale=0; $h * 6 / 1" | bc)
    
    case $h_sector in
        0) r=$c; g=$x; b=0 ;;
        1) r=$x; g=$c; b=0 ;;
        2) r=0; g=$c; b=$x ;;
        3) r=0; g=$x; b=$c ;;
        4) r=$x; g=0; b=$c ;;
        *) r=$c; g=0; b=$x ;;
    esac
    
    # Add m and convert to 0-255 range
    r=$(echo "scale=0; ($r + $m) * 255 / 1" | bc)
    g=$(echo "scale=0; ($g + $m) * 255 / 1" | bc)
    b=$(echo "scale=0; ($b + $m) * 255 / 1" | bc)
    
    # Convert to hex
    printf "#%02x%02x%02x\n" $r $g $b
}

add_profile() {
    local profile_name="$1"
    local fg_h="$2" fg_s="$3" fg_l="$4"
    local bg_h="$5" bg_s="$6" bg_l="$7"
    
    # Check if profiles file exists
    if [[ ! -f "$PROFILES_FILE" ]]; then
        echo "No profiles file found at $PROFILES_FILE"
        echo "Run 'colored-repo init-profiles' to create one first"
        return 1
    fi
    
    # Validate profile name
    if [[ -z "$profile_name" ]]; then
        echo "Error: Profile name is required"
        echo "Usage: colored-repo add <profile-name> <fg-h> <fg-s> <fg-l> <bg-h> <bg-s> <bg-l>"
        echo "Example: colored-repo add my-theme 0 0 100 240 70 30"
        echo "  (white text: h=0, s=0%, l=100% on dark blue: h=240, s=70%, l=30%)"
        return 1
    fi
    
    # Check if profile already exists
    if grep -q "^\[$profile_name\]" "$PROFILES_FILE"; then
        echo "Error: Profile '$profile_name' already exists"
        echo "Use 'colored-repo edit' to modify existing profiles"
        return 1
    fi
    
    # Interactive input if HSL values not provided
    if [[ -z "$fg_h" ]]; then
        echo "Enter foreground color HSL values:"
        printf "Hue (0-360): "; read fg_h
        printf "Saturation (0-100): "; read fg_s
        printf "Lightness (0-100): "; read fg_l
    fi
    
    if [[ -z "$bg_h" ]]; then
        echo "Enter background color HSL values:"
        printf "Hue (0-360): "; read bg_h
        printf "Saturation (0-100): "; read bg_s
        printf "Lightness (0-100): "; read bg_l
    fi
    
    # Validate HSL ranges
    if [[ ! "$fg_h" =~ ^[0-9]+$ ]] || (( fg_h < 0 || fg_h > 360 )); then
        echo "Error: Foreground hue must be 0-360"; return 1
    fi
    if [[ ! "$fg_s" =~ ^[0-9]+$ ]] || (( fg_s < 0 || fg_s > 100 )); then
        echo "Error: Foreground saturation must be 0-100"; return 1
    fi
    if [[ ! "$fg_l" =~ ^[0-9]+$ ]] || (( fg_l < 0 || fg_l > 100 )); then
        echo "Error: Foreground lightness must be 0-100"; return 1
    fi
    if [[ ! "$bg_h" =~ ^[0-9]+$ ]] || (( bg_h < 0 || bg_h > 360 )); then
        echo "Error: Background hue must be 0-360"; return 1
    fi
    if [[ ! "$bg_s" =~ ^[0-9]+$ ]] || (( bg_s < 0 || bg_s > 100 )); then
        echo "Error: Background saturation must be 0-100"; return 1
    fi
    if [[ ! "$bg_l" =~ ^[0-9]+$ ]] || (( bg_l < 0 || bg_l > 100 )); then
        echo "Error: Background lightness must be 0-100"; return 1
    fi
    
    # Convert HSL to hex
    local foreground_hex=$(hsl_to_hex $fg_h $fg_s $fg_l)
    local background_hex=$(hsl_to_hex $bg_h $bg_s $bg_l)
    
    # Add the new profile to the file
    echo "" >> "$PROFILES_FILE"
    echo "[$profile_name]" >> "$PROFILES_FILE"
    echo "foregroundcolor = \"$foreground_hex\"" >> "$PROFILES_FILE"
    echo "backgroundcolor = \"$background_hex\"" >> "$PROFILES_FILE"
    
    echo "✅ Successfully added profile '$profile_name'"
    echo "Foreground: hsl($fg_h, $fg_s%, $fg_l%) → $foreground_hex"
    echo "Background: hsl($bg_h, $bg_s%, $bg_l%) → $background_hex"
    echo ""
    echo "Use 'colored-repo set $profile_name' to apply this profile"
}

show_help() {
    gum style \
        --border double \
        --border-foreground 212 \
        --padding "1 2" \
        --margin "1 0" \
        "Colored Repo - VS Code Workspace Color Profile Manager

Usage:
  colored-repo init-profiles       # Initialize profiles file with examples
  colored-repo list                # Show available color profiles
  colored-repo set                 # Interactive profile selection with gum
  colored-repo add <name>          # Add a new color profile
  colored-repo current             # Show current workspace colors
  colored-repo edit                # Edit profiles file
  colored-repo install             # Install colored-repo globally (symlink to /usr/local/bin)
  colored-repo help                # Show this help message

Available profiles are defined in ~/.colored-repo-profiles
Colors are applied to the current VS Code workspace (.vscode/settings.json)"
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
    
    # Ensure VS Code settings are excluded from git if in a git repository
    if [[ -d ".git" ]]; then
        mkdir -p .git/info
        local exclude_file=".git/info/exclude"
        
        # Check if settings exclusion already exists
        if [[ -f "$exclude_file" ]] && grep -q "\.vscode/[Ss]ettings\.json" "$exclude_file"; then
            # Already excluded, no action needed
            :
        else
            echo "" >> "$exclude_file"
            echo "# VS Code workspace settings (added by colored-repo)" >> "$exclude_file"
            echo ".vscode/Settings.json" >> "$exclude_file"
            echo ".vscode/settings.json" >> "$exclude_file"
            echo "Added VS Code settings exclusion to $exclude_file"
        fi
    fi
    
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