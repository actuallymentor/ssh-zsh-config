read -p "Server ip/domain: " serverip
echo "Server set to $serverip"
read -p "Local ssh key path [default ~/.ssh/deploy.pub]: " sshkey
sshkey=${sshkey:-$HOME/.ssh/deploy.pub}
echo "SSH public key set to $sshkey"
sshpub="$(<$sshkey)"
rootsetup="
sudo useradd --create-home -s /bin/bash deploy
sudo adduser deploy sudo
sudo passwd deploy
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin without-password/g' /etc/ssh/sshd_config
sudo apt-get install -y zsh
"

deploysetup="
# Deploy specific
mkdir -p ~/.ssh
echo \"$sshpub\" >>  ~/.ssh/authorized_keys
service ssh restart
sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)\"
echo 'installed oh my zsh'
chsh -s \$(which zsh)
echo 'zsh installed and switched to'
sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"agnoster\"/g' ~/.zshrc
exit
"

echo "$rootsetup" > rootsetup.sh
echo "$deploysetup" > deploysetup.sh

echo "Copy root script to remote host"
scp ./rootsetup.sh root@$serverip:~
read -p "Connecting as root. Please run ~/rootsetup.sh script and exit when script completes."
ssh root@$serverip
echo "Copy root script to remote host"
scp ./deploysetup.sh deploy@$serverip:~
read -p "Connecting as deploy. Please run ~/deploysetup.sh script and exit when script completes."
ssh deploy@$serverip