# Snippets

Many IDEs offer a feature called "snippets". 

It typically maps a shortcut that you type in your editor to a pre-configured amount of code/text/etc.

This folder contains two snippets you can use to add to the scripts that rely on Bashamtic:O

1. The first one is the raw snippet. If you are using vi, you can run `:r ~/.bashmatic/doc/snippets/raw.sh`
2. If you are using VSCode with BASH extensions, it will support snippets. Press Cmd-P to open the command menu, then search for "shippets", and when you see "Preferences: Configure User Snippets" press ENTER.
3. From the subsequent list, choose `shellscript.json`. 
4. Open Terminal (assuming Bashmatic is loaded), and type: `bashmatic.snippets.vscode`
5. Back in the `shellscript.json` replace the file with the contents of your clipboard.


