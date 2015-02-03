MassRemoteDeploy
================
Often Sys Admins have to do similar kind of tasks on a number of machines. Each and everyone has its own way. Some uses configuration tools like puppet/cfengine. Some uses password less ssh parallel execution or someone might be using either expect or some modules like paramiko to achieve that. 

This is also a similar kind of tool. It exploits the power of **screen**.  What it requires to run.

* A central host having bash
* Same above central host having "screen" utility to be installed.

You do not even need your or root ssh keys in place. It can take care of it. 

What it can provide:
* logging on every host + on central host
* real time visual monitoring. 
* can take actions on individual hosts as well.

Caveats:
* Only for private network.
* Knowing screen usage is advantageous. 

  
**HowtoRun**
=========
Unzip all files in your home folder in some central machine. 
```bash
cd SCREEN_TEST
```
create a direcotry inside RELEASES directory and name it whatever you like. lets say e.g.  TEST
additionally create a script or program that you want to run on all target machines inside RELESES/TEST dir.(This step is not
mandatory)
run following command and following the instructions on screen.
```bash
./generate_screenrc_files_and_push_required_files.sh TEST
```
Additonally just run `./generate_screenrc_files_and_push_required_files.sh <enter> `to view one more option



  
