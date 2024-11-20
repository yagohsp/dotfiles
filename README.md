run in powershell admin
```
git clone git@github.com:yagohsp/dotfiles.git .dotfiles; .dotfiles/Set-ProfilePath.ps1; [System.Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", "$HOME\.dotfiles", [System.EnvironmentVariableTarget]::User)
```
