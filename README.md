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
  

  
