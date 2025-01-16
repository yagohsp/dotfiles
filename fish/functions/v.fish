function v
    if test -f $argv[1]
        set dir (dirname $argv[1])
        cd $dir
        /usr/bin/nvim $argv[1] 
    else
        cd $argv[1] && /usr/bin/nvim $argv[1] 
    end
end
