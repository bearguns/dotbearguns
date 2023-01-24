function dotfiles --wraps git --description "Manage dotfiles repo"
    git --git-dir=$HOME/.bearguns/ --work-tree=$HOME $argv
end
