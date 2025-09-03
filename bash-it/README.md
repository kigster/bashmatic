# Powerline Multiline Overrides

This folder contains color and other overrides for the widely used
BASH framework [Bash-It](https://github.com/bash-it/bash-it). 

One of the "themes" in that framework is "powerline-multiline" which 
requires either "powerline" or "nerd" fonts, or if you are using iTerm2
you can turn on Powerline Characters by going into the "Text" tab
of the profile and turning the appropriate checkbox on.

## Usage

In your `~/.bash_profile` uncomment the line:

```bash
export SHORT_HOSTNAME=$(hostname -s)
```

Right around when you source `bash_it.sh`, put the following:

```bash
source "$BASH_IT"/bash_it.sh
export NODE_VERSION_STRATEGY=native
source "${HOME}/.bashmatic/bash-it/powerline-multiline.theme.bash"
```

If you are using iTerm, we recommend "Havn Scarving" theme. 

## License

MIT

## Copyright

© Konstantin Gredeskoul
