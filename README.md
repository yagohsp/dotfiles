```
git clone --recurse-submodules -j8 git@github.com:yagohsp/dotfiles.git
```

run in powershell admin
```
git clone git@github.com:yagohsp/dotfiles.git .dotfiles; .dotfiles/SetConfigs.ps1; [System.Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", "$HOME\.dotfiles", [System.EnvironmentVariableTarget]::User)
```
