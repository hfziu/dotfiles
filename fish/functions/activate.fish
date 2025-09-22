# Activate a Python virtual environment from ~/.virtualenvs
#
# Assumes virtual environments have activate.fish (true for virtual environments created with recent versions of astral-sh/uv)

function activate --description "Activate a Python virtual environment from ~/.virtualenvs"
    if not test -d "$HOME/.virtualenvs"
        echo "Error: Directory ~/.virtualenvs does not exist"
        return 1
    end
    
    if test (count $argv) -ne 1
        echo "Usage: activate <virtualenv_name>"
        return 1
    end
    
    set -l venv_path "$HOME/.virtualenvs/$argv[1]/bin/activate.fish"
    
    if test -f "$venv_path"
        source "$venv_path"
    else
        echo "Warning: activate.fish not found for virtual environment '$argv[1]'"
        echo "Expected at: $venv_path"
    end
end