#!/bin/bash
set -e -x

get_dotfiles () {

    echo "(1/4): GETTING DOTFILES..."
    local DIR=$HOME
    # git clone https://github.com/aws-samples/ec2-data-science-vim-tmux-zsh.git $DIR/dotfiles
    git clone https://github.com/HankTak/dotfiles.git $DIR
    ln -s $DIR/dotfiles/dotfiles/vim/vimrc $DIR/.vimrc
    ln -s $DIR/dotfiles/dotfiles/tmux/tmux.conf $DIR/.tmux.conf
    ln -s $DIR/dotfiles/dotfiles/zsh/zshrc $DIR/.zshrc
    ln -s $DIR/dotfiles/dotfiles/zsh/.p10k.zsh $DIR/.p10k.zsh
    ln -s $DIR/dotfiles/dotfiles/alacritty/alacritty.toml $DIR/.alacritty.toml
    chown -R $USER:$USER $DIR/dotfiles $DIR/.vimrc $DIR/.tmux.conf $DIR/.zshrc $DIR/.p10k.zsh  $DIR/.alacritty.toml
}

setup_vim () {

    echo "(2/4) SETTING UP VIM..."
    local DIR=$HOME
    # Install black for formatting
    # pip3 install black

    # Install vim plug for package management
    curl -fLo $DIR/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    chown -R $USER:$USER $DIR/.vim
    # Install packages
    sudo runuser -l $USER -c 'vim +PlugInstall +qall'

    # Install YCM
    cd $DIR/.vim/plugged/YouCompleteMe
    python3 ./install.py --clang-completer  

}

setup_tmux () {

    echo "(3/4) SETTING UP TMUX..."
    # Install tmux dependencies
    sudo apt-get -y install libncurses-dev
    sudo apt-get -y install libevent-dev

    # Get the latest version of tmux
    git clone https://github.com/tmux/tmux.git
    cd tmux
    sh autogen.sh
    ./configure
    sudo  make install
    cd ..
    # Get a simple startup script
    sudo mv $HOME/dotfiles/dotfiles/stm.sh /bin/stm 
    sudo chmod +x /bin/stm
    # Install htop
    sudo apt-get -y install htop
    # Install fzf
    sudo apt install fzf
    #Install zoxide
    sudo apt install zoxide
    #Install ctags
    sudo apt install universal-ctags
    #Install trash-cli
    sudo apt install trash-cli
}

setup_zsh () {

    echo "(4/4) SETTING UP ZSH..."
    local DIR=$HOME
    sudo apt-get -y update && sudo apt-get -y install zsh
    # Install oh-my-zsh
    wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O $DIR/install.sh
    sudo chown -R $USER:$USER $DIR/install.sh
    cd $DIR
    echo pwd
    sudo runuser -l $USER 'install.sh'
    # Change the default shell to zsh
    sudo apt-get -y install util-linux-user
    chsh -s /bin/zsh $USER
    # Add conda to end of zshrc
    echo "source ~/.dlamirc" >> $DIR/.zshrc
    #Install powerlevel10k
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    #Install custom plugin
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone --depth 1 https://github.com/unixorn/fzf-zsh-plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-zsh-plugin
}

setup_alacritty () {
    echo "() SETTTING UP  ACLACRITTY..."
    sudo snap install alacritty --classic
    mkdir -p ~/.config/alacritty/themes
    git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
}

get_dotfiles
setup_vim
setup_tmux
setup_zsh

