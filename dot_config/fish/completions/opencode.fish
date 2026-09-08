# Fish shell completions for opencode
# https://opencode.ai

# Disable file completions for the main command
complete -c opencode -f

# Global options
complete -c opencode -s h -l help        -d 'Show help'
complete -c opencode -s v -l version     -d 'Show version number'
complete -c opencode -s m -l model       -d 'Model to use (provider/model)' -r
complete -c opencode -s c -l continue    -d 'Continue the last session'
complete -c opencode -s s -l session     -d 'Session ID to continue' -r
complete -c opencode -l fork             -d 'Fork the session when continuing'
complete -c opencode -l print-logs       -d 'Print logs to stderr'
complete -c opencode -l log-level        -d 'Log level' -r -a 'DEBUG INFO WARN ERROR'
complete -c opencode -l pure             -d 'Run without external plugins'
complete -c opencode -l port             -d 'Port to listen on' -r
complete -c opencode -l hostname         -d 'Hostname to listen on' -r
complete -c opencode -l mdns             -d 'Enable mDNS service discovery'
complete -c opencode -l mdns-domain      -d 'Custom domain name for mDNS service' -r
complete -c opencode -l cors             -d 'Additional domains to allow for CORS' -r

# Top-level subcommands
complete -c opencode -n '__fish_use_subcommand' -a completion  -d 'Generate shell completion script'
complete -c opencode -n '__fish_use_subcommand' -a acp         -d 'Start ACP server'
complete -c opencode -n '__fish_use_subcommand' -a mcp         -d 'Manage MCP servers'
complete -c opencode -n '__fish_use_subcommand' -a attach      -d 'Attach to a running opencode server'
complete -c opencode -n '__fish_use_subcommand' -a run         -d 'Run opencode with a message'
complete -c opencode -n '__fish_use_subcommand' -a debug       -d 'Debugging and troubleshooting tools'
complete -c opencode -n '__fish_use_subcommand' -a providers   -d 'Manage AI providers and credentials'
complete -c opencode -n '__fish_use_subcommand' -a auth        -d 'Manage AI providers and credentials (alias)'
complete -c opencode -n '__fish_use_subcommand' -a agent       -d 'Manage agents'
complete -c opencode -n '__fish_use_subcommand' -a upgrade     -d 'Upgrade opencode to latest or specific version'
complete -c opencode -n '__fish_use_subcommand' -a uninstall   -d 'Uninstall opencode and remove all related files'
complete -c opencode -n '__fish_use_subcommand' -a serve       -d 'Start a headless opencode server'
complete -c opencode -n '__fish_use_subcommand' -a web         -d 'Start opencode server and open web interface'
complete -c opencode -n '__fish_use_subcommand' -a models      -d 'List all available models'
complete -c opencode -n '__fish_use_subcommand' -a stats       -d 'Show token usage and cost statistics'
complete -c opencode -n '__fish_use_subcommand' -a export      -d 'Export session data as JSON'
complete -c opencode -n '__fish_use_subcommand' -a import      -d 'Import session data from JSON file or URL'
complete -c opencode -n '__fish_use_subcommand' -a github      -d 'Manage GitHub agent'
complete -c opencode -n '__fish_use_subcommand' -a pr          -d 'Fetch and checkout a GitHub PR branch, then run opencode'
complete -c opencode -n '__fish_use_subcommand' -a session     -d 'Manage sessions'
complete -c opencode -n '__fish_use_subcommand' -a plugin      -d 'Install plugin and update config'
complete -c opencode -n '__fish_use_subcommand' -a plug        -d 'Install plugin and update config (alias)'
complete -c opencode -n '__fish_use_subcommand' -a db          -d 'Database tools'

# mcp subcommands
complete -c opencode -n '__fish_seen_subcommand_from mcp' -a add    -d 'Add an MCP server'
complete -c opencode -n '__fish_seen_subcommand_from mcp' -a list   -d 'List MCP servers and their status'
complete -c opencode -n '__fish_seen_subcommand_from mcp' -a ls     -d 'List MCP servers and their status (alias)'
complete -c opencode -n '__fish_seen_subcommand_from mcp' -a auth   -d 'Authenticate with an OAuth-enabled MCP server'
complete -c opencode -n '__fish_seen_subcommand_from mcp' -a logout -d 'Remove OAuth credentials for an MCP server'
complete -c opencode -n '__fish_seen_subcommand_from mcp' -a debug  -d 'Debug OAuth connection for an MCP server'

# providers subcommands
complete -c opencode -n '__fish_seen_subcommand_from providers auth' -a list   -d 'List providers and credentials'
complete -c opencode -n '__fish_seen_subcommand_from providers auth' -a ls     -d 'List providers and credentials (alias)'
complete -c opencode -n '__fish_seen_subcommand_from providers auth' -a login  -d 'Log in to a provider'
complete -c opencode -n '__fish_seen_subcommand_from providers auth' -a logout -d 'Log out from a configured provider'

# session subcommands
complete -c opencode -n '__fish_seen_subcommand_from session' -a list   -d 'List sessions'
complete -c opencode -n '__fish_seen_subcommand_from session' -a delete -d 'Delete a session'

# agent subcommands
complete -c opencode -n '__fish_seen_subcommand_from agent' -a create -d 'Create a new agent'
complete -c opencode -n '__fish_seen_subcommand_from agent' -a list   -d 'List all available agents'

# github subcommands
complete -c opencode -n '__fish_seen_subcommand_from github' -a install -d 'Install the GitHub agent'
complete -c opencode -n '__fish_seen_subcommand_from github' -a run     -d 'Run the GitHub agent'

# debug subcommands
complete -c opencode -n '__fish_seen_subcommand_from debug' -a config   -d 'Show resolved configuration'
complete -c opencode -n '__fish_seen_subcommand_from debug' -a lsp      -d 'LSP debugging utilities'
complete -c opencode -n '__fish_seen_subcommand_from debug' -a rg       -d 'Ripgrep debugging utilities'
complete -c opencode -n '__fish_seen_subcommand_from debug' -a file     -d 'File system debugging utilities'
complete -c opencode -n '__fish_seen_subcommand_from debug' -a scrap    -d 'List all known projects'
complete -c opencode -n '__fish_seen_subcommand_from debug' -a skill    -d 'List all available skills'
complete -c opencode -n '__fish_seen_subcommand_from debug' -a snapshot -d 'Snapshot debugging utilities'
complete -c opencode -n '__fish_seen_subcommand_from debug' -a agent    -d 'Show agent configuration details'
complete -c opencode -n '__fish_seen_subcommand_from debug' -a paths    -d 'Show global paths (data, config, cache, state)'
complete -c opencode -n '__fish_seen_subcommand_from debug' -a wait     -d 'Wait indefinitely (for debugging)'
