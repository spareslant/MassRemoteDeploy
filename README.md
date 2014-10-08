MassRemoteDeploy
================
Often Sys Admins have to do similar kind of tasks on a number of machines. Each and everyone has its own way. Some uses configuration tools like puppet/cfengine. Some uses password less ssh parallel execution or someone might be using either expect or some modules like paramiko to achieve that. 

This is also a similar kind of tool. All it need is a screen utility to be installed on some central machine from which jobs can be fired on target hosts.

With this tool , process for a mass deployment would be like:

  1) A command to Initiate multiple connections to target hosts. ( I have tested 40 simultaneous connections without any issues)
  
  2) A command to supply user password that will log him/her into above multiple connections.
  
  3) A command to fire the job to above connections.
  
  4) It generates log from each machine on central location. It can also generate logs on target machine along with central
     location.
  
  5) Real time visual monitoring can be done for each connection in addition to logging.  
  
  6) Each connection can be handled separately as well.
  
HowtoRun
=========
Unzip all files in your home folder in some central machine. 

cd SCREEN_TEST

create a direcotry inside RELEASES directory and name it whatever you like. lets say e.g.  TEST

additionally create a script or program that you want to run on all target machines inside RELESES/TEST dir.(This step is not
mandatory)

run following command and following the instructions on screen.
./generate_screenrc_files_and_push_required_files.sh TEST

Additonally just run ./generate_screenrc_files_and_push_required_files.sh <enter> to view one more option



  
