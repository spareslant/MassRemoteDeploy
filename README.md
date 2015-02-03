MassRemoteDeploy
================
Often Sys Admins have to do similar kind of tasks on a number of machines. Each and everyone has its own way. Some uses configuration tools like puppet/cfengine. Some uses password less ssh parallel execution or someone might be using either expect or some modules like paramiko to achieve that. 

This is also a similar kind of tool. It exploits the power of **screen**.  What it requires to run.

1) A central host having bash

2) Same above central host having "screen" utility to be installed.

You do not even need your or root ssh keys in place. It can take care of it. 

What it can provide:
1) logging on every host + on central host

2) real time visual monitoring. 

3) can take actions on individual hosts as well.

Caveats:

1) Only for private network.

2) Knowing screen usage is advantageous. 

  
**HowtoRun**
=========
Unzip all files in your home folder in some central machine. 

cd SCREEN_TEST

create a direcotry inside RELEASES directory and name it whatever you like. lets say e.g.  TEST

additionally create a script or program that you want to run on all target machines inside RELESES/TEST dir.(This step is not
mandatory)

run following command and following the instructions on screen.
./generate_screenrc_files_and_push_required_files.sh TEST

Additonally just run ./generate_screenrc_files_and_push_required_files.sh <enter> to view one more option



  
