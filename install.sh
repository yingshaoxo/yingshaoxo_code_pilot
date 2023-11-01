if which git >/dev/null; then
    echo "git is installed."
else
    echo "git is not installed. Installation Failed."
    exit 0
fi

if which curl >/dev/null; then
    echo "curl is installed."
else
    echo "curl is not installed. Installation Failed."
    exit 0
fi

if which python3 >/dev/null; then
    the_real_py_command="python3"
    echo "python3 is installed."
else
    echo "python3 is not installed. Installation Failed."
    exit 0
fi



mkdir -p ~/.vim/pack
cd ~/.vim/pack
git clone https://github.com/yingshaoxo/yingshaoxo_code_pilot.git



#if $the_real_py_command -m pip >/dev/null; then
#    echo "pip is installed."
#else
#    curl -sSL https://bootstrap.pypa.io/get-pip.py | $the_real_py_command
#fi
#
#if $the_real_py_command -m pip show auto_everything > /dev/null; then
#    echo "python package auto_everything installed."
#else
#    $the_real_py_command -m pip install "git+https://github.com/yingshaoxo/auto_everything.git@dev"
#fi


echo "yingshaoxo_code_pilot Installation Finished."
