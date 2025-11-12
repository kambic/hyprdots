#!/usr/bin/fish

function get_gpu_paths
    find /sys/class/drm -name "card*" -type l | grep -v "render" | sort
end

function get_hwmon_path -a card_path
    set hwmon_dir "$card_path/device/hwmon"
    
    if test -d "$hwmon_dir"
        find "$hwmon_dir" -name "hwmon*" -type d | head -1
    end
end

function amd_gpu_max
    echo "Tuning AMD GPU for maximum performance..."
    
    set gpu_paths (get_gpu_paths)
    
    if test -z "$gpu_paths"
        echo "Warning: No GPU devices found"
        return 1
    end
    
    for card_path in $gpu_paths
        if not test -d "$card_path/device"
            continue
        end
        
        # Set performance level
        if test -w "$card_path/device/power_dpm_force_performance_level"
            echo "manual" > "$card_path/device/power_dpm_force_performance_level"
        end
        
        # Set power profile mode
        if test -w "$card_path/device/pp_power_profile_mode"
            echo "1" > "$card_path/device/pp_power_profile_mode"
        end
        
        # Set memory clock
        if test -w "$card_path/device/pp_dpm_mclk"
            echo "3" > "$card_path/device/pp_dpm_mclk"
        end
        
        # Set power cap
        set hwmon_path (get_hwmon_path "$card_path")
        if test -n "$hwmon_path"; and test -w "$hwmon_path/power1_cap"
            echo "156000000" > "$hwmon_path/power1_cap"
        end
    end
end

function power_saver
    echo "Setting power-saver profile..."
    
    if command -v powerprofilesctl >/dev/null 2>&1
        powerprofilesctl set power-saver; or begin
            echo "Error: Failed to set power-saver profile"
            return 1
        end
    else
        echo "Warning: powerprofilesctl not found"
    end
    
    echo "Power-saver profile activated"
end

function balanced
    echo "Setting balanced profile..."
    
    if command -v systemd-cat >/dev/null 2>&1
        echo "Loading balanced" | systemd-cat
    end
    
    if command -v powerprofilesctl >/dev/null 2>&1
        powerprofilesctl set balanced; or begin
            echo "Error: Failed to set balanced profile"
            return 1
        end
    else
        echo "Warning: powerprofilesctl not found"
    end
    
    echo "Balanced profile activated"
end

function performance
    echo "Setting performance profile..."
    
    if command -v systemd-cat >/dev/null 2>&1
        echo "Setting performance profile" | systemd-cat
    end
    
    if command -v powerprofilesctl >/dev/null 2>&1
        powerprofilesctl set performance; or begin
            echo "Error: Failed to set performance profile"
            return 1
        end
    else
        echo "Warning: powerprofilesctl not found"
    end
    
    amd_gpu_max
    echo "Performance profile activated"
end

function show_help
    echo "Usage: "(basename (status current-filename))" [OPTION]"
    echo "Set power profile for HP Z4G4 workstation"
    echo
    echo "Options:"
    echo "  -s, --power-saver    Set power-saver profile"
    echo "  -b, --balanced       Set balanced profile"
    echo "  -p, --performance    Set performance profile"
    echo "  -h, --help           Display this help and exit"
    echo
    echo "Examples:"
    echo "  "(basename (status current-filename))" --power-saver"
    echo "  "(basename (status current-filename))" -p"
end

# Main script execution
switch "$argv[1]"
    case -s --power-saver
        power_saver
    case -b --balanced
        balanced
    case -p --performance
        performance
    case -h --help
        show_help
        exit 0
    case ""
        echo "Error: No option provided"
        show_help
        exit 1
    case '*'
        echo "Error: Invalid option '$argv[1]'"
        show_help
        exit 1
end
