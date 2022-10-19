#!/bin/bash
### /Script Documentation: Backup Amazon Instance 221020 Ver 1.0
#Stop your amazon instance!  The go to your control panel and unattach any volume you want to backup to your local machine.  
#Connect it to a new (say cloned) instance as a seconday drive (don't boot off it).  Then run this script locally in a 
#directory you want a compressed image to be saved.  

#The script uses serverside cpu on light xz compression settings (3 of 9) and minimizes export bandwidth without 
#taking forever with cpu throttling. Save money on amazon storage for backing up by xfiltrating your boot volume! 
#Take your data into your own hands and make your AWS server portable!


#User instructions
echo "To back up your Amazon AWS boot volume:"
echo "	-shutdown/stop the instance (AWS Control Panel)"
echo "	-unattach volume (AWS CP)"
echo "	-clone instance (or use a temp)"
echo " "
echo "	-attach volume as a secondary drive (should become xvdf)"
echo "	-launch the cloned/temp instance"
echo "	-make note of the volume device id (xvdf, sda, sda1 etc..) in the temp server's OS"
echo "	(terminal commands: df -a -h or blkid)"
echo " "
echo "  -Script will save the file to the working directory"
echo " "
echo "Press the ANY key and ENTER when ready..."
read press_anykey
echo " "
echo " "

# install xz-utils
echo "Do you have xz installed?"
echo "	(sudo apt install xz-utils)"
echo " " 
echo "(y)es / (n)o / (n)ot sure"
read xz_Choice
if [ $xz_Choice = "n" ]
	then
	sudo apt-get install xz-utils
fi
echo " "

#Will ask for AWS temp server USER/IP, location of local PEM file, and location for 7z 
echo "Input your AWS clone/temp Username: and IP:"
echo "	(the one where you have the disk or partition you want to backup)"
echo "	eg	ubuntu   	<enter>
	 	3.123.123.12   	<enter>"
read aws_usr
read aws_ip
pem_path=""
echo "Input the .pem file PATH:"
echo "	eg /home/USERNAME/Documents/AWS_AUTH.pem"
echo " 	If you don't use a pem authentication file leave blank"
pem_path=""
read pem_path

#killed option to allow user to select path (too buggy)
save_path=$(pwd)

echo "Input device id of the volume to be backed up?"
echo "	eg xvdf or sda or sda1"
read dev_id

echo "Installing xz-utils on your server..."

#conditionally fix pem path to reference a pem file (eg ssh -i pemfile.pem usr@ip)
if [ -z "$pem_path" ]
then
      echo NULL
else
      pem_path="-i ${pem_path}"
fi

#install xz utils on server
ssh $pem_path $aws_usr"@"$aws_ip sudo apt-get install xz-utils
sleep 0.5; echo "."; sleep 0.5; echo ".."; sleep 0.5; echo "..."; sleep 1;
#clear

echo "xz compressing and sending to your local path.."
sleep 0.5; echo "."; sleep 0.5; echo ".."; sleep 0.5; echo "..."; sleep 1;


ssh_cmd1="$pem_path $aws_usr"@"$aws_ip"
ssh_cmd2="sudo dd if=/dev/"$dev_id" bs=8M status=progress | xz -c -3"
dd_local_cmd="dd of=$save_path"/"$(date +%y%m%d_%H%M)-AWS.img.xz"

ssh ${ssh_cmd1} "$ssh_cmd2" | ${dd_local_cmd}

#exit
$SHELL

















