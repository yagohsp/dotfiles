oh-my-posh init pwsh --config 'C:\Users\Yago\AppData\Local\Programs\oh-my-posh\themes\zash.omp.json' | Invoke-Expression

Set-PSReadLineKeyHandler -Key ctrl+f -Function AcceptSuggestion
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit

$nvim = "~\dotfiles\nvim"
