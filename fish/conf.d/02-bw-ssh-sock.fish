set -l bitwarden_ssh_auth_sock "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock"

if test -S "$bitwarden_ssh_auth_sock"
	set -gx SSH_AUTH_SOCK "$bitwarden_ssh_auth_sock"
end
