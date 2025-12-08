# Aliases ollama to run inside the 'ollama' Docker container if it is running.

function cont_ollama
    echo "ollama command is now aliased to run inside the 'ollama' container."
end

function ollama --description 'Run ollama inside ollama container'
    docker exec -it ollama ollama $argv
end
