mkdir -p ~/.vim/pack
cd ~/.vim/pack
git clone https://github.com/yingshaoxo/yingshaoxo_code_pilot.git

curl -sSL https://bootstrap.pypa.io/get-pip.py | python
curl -sSL https://bootstrap.pypa.io/get-pip.py | python3

#pip install auto_everything -y
pip install "git+https://github.com/yingshaoxo/auto_everything.git@dev"
