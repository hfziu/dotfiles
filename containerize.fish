#!/usr/bin/env fish

set -l base_dir (status dirname)
set -l src_dir "$base_dir/fish/functions"
set -l dest_dir "$HOME/.config/fish/functions"
set -l targets cont_pg.fish cont_ollama.fish

function do_enable --inherit-variable src_dir --inherit-variable dest_dir --inherit-variable targets
    mkdir -p $dest_dir
    for f in $targets
        cp "$src_dir/$f" "$dest_dir/"
        set_color green; echo "Installed $f to $dest_dir"; set_color normal
    end
    echo ""
    set_color yellow
    echo "You need to run 'cont_*' once in each session to activate aliases."
    echo "Currently supported: cont_pg, cont_ollama"
    set_color normal
end

function do_disable --inherit-variable dest_dir --inherit-variable targets
    for f in $targets
        if test -e "$dest_dir/$f"
            rm "$dest_dir/$f"
            set_color red; echo "Removed $f from $dest_dir"; set_color normal
        else
            set_color yellow; echo "$f not found in $dest_dir"; set_color normal
        end
    end
end

if test (count $argv) -gt 0
    switch $argv[1]
        case on enable
            do_enable
        case off disable
            do_disable
        case '*'
            set_color red; echo "Usage: ./containerize.fish [on|off]"; set_color normal
            exit 1
    end
else
    set_color cyan; echo "Manage containerized command aliases ($targets)"; set_color normal
    echo "1. Enable"
    echo "2. Disable"
    read -P "Select an option (1/2): " choice

    switch $choice
        case 1
            do_enable
        case 2
            do_disable
        case '*'
            set_color red; echo "Invalid selection"; set_color normal
            exit 1
    end
end
