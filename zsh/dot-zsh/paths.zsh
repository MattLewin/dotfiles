# ML: 2015-10-08
# ML: Moved the stuff below from ~/.zshrc when I realized it should be here in .../custom
#

# echo "Setting Matt's custom paths in $0"

# ML: 2014-12-05
if [ -d $HOME/bin ]; then
	export PATH=$PATH:$HOME/bin
fi

# ML: 2015-01-11
if [ -d /usr/local/sbin ]; then
	export PATH=$PATH:/usr/local/sbin
fi

# ML: 2015-10-08
#     As of El Capitan (OS X 10.11), /usr/local/bin magically disappeared from my PATH
#
if [ -d /usr/local/bin ]; then
	export PATH=/usr/local/bin:$PATH
fi

# So did /usr/sbin
if [ -d /usr/sbin ]; then
	export PATH=$PATH:/usr/sbin
fi

# ML: 2015-10-23
# And /sbin
# What a pain in the butt
if [ -d /sbin ]; then
	export PATH=$PATH:/sbin
fi

# ML: 2017-05-22
if [ -d $HOME/src/go/bin ]; then
	export PATH=$PATH:$HOME/src/go/bin
fi

# ML: 2018-08-29
test -d "${HOME}/swift" && export PATH=${HOME}/swift/usr/bin:${PATH}

# ML: 2018-08-30
test -d "${HOME}/.cargo/bin" && export PATH=${PATH}:${HOME}/.cargo/bin

# ML: 2018-11-07
test -d "${HOME}/.fastlane/bin" && export PATH=${PATH}:${HOME}/.fastlane/bin

# ML: 2018-11-09
test -d "${HOME}/Library/Android/sdk" && export PATH=${PATH}:${HOME}/Library/Android/sdk/platform-tools
