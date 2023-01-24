if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
end
set -Ux FONTAWESOME_NPM_AUTH_TOKEN 7663850B-0131-49C0-A909-F732E685236D

set --universal nvm_default_version v16.18.0
set --universal nvm_default_packages @volar/vue-language-server

