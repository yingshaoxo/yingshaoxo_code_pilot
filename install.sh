mkdir -p ~/.vim/pack
cd ~/.vim/pack
git clone https://github.com/yingshaoxo/yingshaoxo_code_pilot.git

#pip install auto_everything -y

curl -sSL https://bootstrap.pypa.io/get-pip.py | python
pip install "git+https://github.com/yingshaoxo/auto_everything.git@dev" -y
