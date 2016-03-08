#! /bin/bash


HOST_SCREEN_RC_FILES_DIR="SCREEN_RC_FILES"
MAIN_RC_FILE="mainscreenrc"
LOG_DIR="LOGS"
TOOL_HOMEDIR=$(pwd)
TASKS_DIR="REMOTE_TASKS"
USAGE="usage is: $(basename $0) <Task DIRECTORY>\ne.g. $(basename $0) INSTALL_APPS
or
$(basename $0) SSHKEYCOPY

Note:
1. Create a file \"boxes\" and append hostnames in it one per line. Lines starting with # will be ignored.
2. Create a directory inside $TASKS_DIR that would optionally contain script/files to be executed/places on remote machines. e.g. $TASKS_DIR/INSTALL_APPS
3. Above created directory name will be the argument to this script.

e.g. $(basename $0) INSTALL_APPS"
SCP_COMMAND="/usr/bin/scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o PreferredAuthentications=hostbased,publickey,password"


mkdir -p $HOST_SCREEN_RC_FILES_DIR
mkdir -p $LOG_DIR
mkdir -p $TASKS_DIR
TASK="$1"

if [[ "$TASK" == "SSHKEYCOPY" ]]
then
    mkdir -p $TASKS_DIR/SSHKEYCOPY
fi


LOGGED_SESSION_SCREENRC_FILE="logged_in_screen_config"

[[ -z "$TASK" ]] && printf "$USAGE\n Exiting..\n" && exit 2

if [[ ! -d $TASKS_DIR/$TASK ]]
then
        echo "$TASKS_DIR/$TASK does not exist. Exiting.."
        exit 1
fi

echo "Cleaning up old log files and rc files for machines mentioned in boxes file:"
for host in `egrep -v '^#|^$' boxes`
do
        ( cd $LOG_DIR ; rm -f ${host}.log.raw ; cd ../$HOST_SCREEN_RC_FILES_DIR ; rm -f *_rc )
done

echo "----- Generating top screenrc file -----"

(cat <<-MAINSCREENRC
startup_message off
defscrollback 500
defutf8 on
hardstatus on
hardstatus alwayslastline
hardstatus string "%{+b r} %t"
MAINSCREENRC
) > $MAIN_RC_FILE


echo "----- Generating screenrc file used in logged in session -----"

(cat <<-SESSIONRCFILE
logfile /tmp/$TASK/screen.raw.log
deflog on
SESSIONRCFILE
) > $TASKS_DIR/$TASK/$LOGGED_SESSION_SCREENRC_FILE



if [[ $TASK == "SSHKEYCOPY" ]]
then
for host in `egrep -v '^#|^$' boxes`
do
    echo "=====Checking password less login to {{ $host }}====="
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o PreferredAuthentications=hostbased,publickey,password $host "uname -a"
    if [[ $? -eq 0 ]]
    then
        echo -e "\e[42mPASS: $host already has ssh keys.\e[0m"
        continue
    else
        echo -e "\e[41mFAIL: $host does not have ssh keys.\e[0m"
    fi
    mkdir -p $TASKS_DIR/$TASK/${host}_export
    echo "export TARGETHOST=$host" > $TASKS_DIR/$TASK/${host}_export/${host}_export
echo "------ Generating screenrc file for $host -----"
(cat <<-SCREENSTART
screen -t $host
select $host
logfile LOGS/$host.log.raw
log on
stuff "source $TOOL_HOMEDIR/$TASKS_DIR/$TASK/${host}_export/${host}_export"`echo -ne '\015'`
detach
SCREENSTART
 ) > $HOST_SCREEN_RC_FILES_DIR/${host}_rc
echo "source $HOST_SCREEN_RC_FILES_DIR/${host}_rc" >> $MAIN_RC_FILE
done

    echo "# Make sure boxes file is populated with target hostnames"
    echo ""
    echo "# Run following command in a terminal"
    echo "./$(basename $0) $TASK"
    echo ""
    echo "# Open 2nd Terminal Window : Run following to start Screen sessions with multiple windows:"
    echo "cd $TOOL_HOMEDIR ; screen -S MasterSession -c $MAIN_RC_FILE"
    echo ""
    echo "# On 2nd Terminal Window: Run following command:"
    echo "screen -r  <Now Press ctrl-a,ctrl-\" to check all connections>"
    echo ""
    echo "# Open 3rd Terminal window : Grab the contents of file (your password in this file appended by ctrl-v,ctrl-Enter ie. ^M character appended after your password):"
    echo "cd $TOOL_HOMEDIR ; screen -S MasterSession -X readbuf ./passwd_file"
    echo ""
    echo "# Open 3rd Terminal window : run command to copy ssh keys"
    echo "screen -S MasterSession -X at \"#\" stuff \$'ssh-keyscan -t rsa \\\$TARGETHOST >> \$HOME/.ssh/known_hosts ; ssh-copy-id -i \$HOME/.ssh/id_rsa.pub \\\$TARGETHOST\n'  (Preferred command)"
    echo "screen -S MasterSession -X at \"#\" stuff \$'cat \$HOME/.ssh/*.pub | ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \\\$TARGETHOST  \"cat - > \$HOME/.ssh/authorized_keys\"\n'"
    echo ""
    echo "# On 3rd Terminal Window : paste your password"
    echo "screen -S MasterSession -X at \"#\" paste \".\""
    echo ""

else
for host in `egrep -v '^#|^$' boxes`
do
echo "------ Generating screenrc file for $host -----"
(cat <<-SCREENSTART
screen -t $host ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $host
select $host
logfile LOGS/$host.log.raw
log on
detach
SCREENSTART
 ) > $HOST_SCREEN_RC_FILES_DIR/${host}_rc
echo "source $HOST_SCREEN_RC_FILES_DIR/${host}_rc" >> $MAIN_RC_FILE
done

for host in `egrep -v '^#|^$' boxes`
do
        echo "=====pushing {{ $TASK }} files to $host====="

        $SCP_COMMAND -pr $TASKS_DIR/$TASK $host:/tmp
        if [[ $? -ne 0 ]]
        then
            echo -e "\e[41mERROR: Files not copied for $host.\e[0m"
        fi

done

echo "=========================================="
echo "# Open 2nd Terminal Window : Run following to start Screen sessions with multiple windows:"
echo "cd $TOOL_HOMEDIR ; screen -S MasterSession -c $MAIN_RC_FILE"
echo ""
echo "# On 2nd Terminal Window: Run following command:"
echo "screen -r  <Now Press ctrl-a,ctrl-\" to check all connections>"
echo ""
echo "# Open 3rd Terminal window : Grab the contents of file (your password in this file appended by ctrl-v,ctrl-Enter ie. ^M character appended after your password):"
echo "cd $TOOL_HOMEDIR ; screen -S MasterSession -X readbuf ./passwd_file"
echo ""
echo "# On 3rd Terminal : Send contents from user input directly:"
#echo "screen -S MasterSession -X at \"#\" stuff \"sudo su -^M\" (Press ctrl-v ctrl-Enter for ^M)"
echo "screen -S MasterSession -X at \"#\" stuff \$'sudo su -\n'"
#echo "screen -S MasterSession -X at \"#\" stuff \"sudo su -\"\`echo -ne '\015'"
echo ""
echo "# On 3rd Terminal : Send Grabbed contents to all Windows in MasterSession screen session:"
echo "screen -S MasterSession -X at \"#\" paste \".\""
echo "# On 3rd Terminal : Send Grabbed contents to a particular window:"
echo "screen -S MasterSession -p machine1 -X paste \".\""
echo ""
echo "# On 3rd Terminal : IF REQUIRED run screen session in logged in session as well"
echo "screen -S MasterSession -X at \"#\" stuff \$'screen -S R$TASK -c /tmp/$TASK/$LOGGED_SESSION_SCREENRC_FILE\n'"
echo ""
echo "# On 3rd Terminal : Now you can run commands as root user using screen's stuff command as described above"
echo "# On 3rd Terminal : You can also run script/program that might have been copied in /tmp/$TASK directory using stuff command"
echo "screen -S MasterSession -X at \"#\" stuff \$'cd /tmp/$TASK ; bash ./<yourscripthere.sh>\n'"
echo ""
echo "# On 3rd Terminal : To restart services in random time order"
echo "screen -S MasterSession -X at \"#\" stuff \"sleep \\\$(perl -e 'printf \"%d\n\",rand() * 10');/etc/init.d/someservice stop;sleep \\\$(perl -e 'printf \"%d\n\",rand() * 10');/etc/init.d/gridpipeline start^M\""
echo ""
echo "# On 3rd Terminal : To monitor all sessions in a cycle repeatedly, run following and then switchover to 2nd terminal window to monitor it"
echo "while true; do screen -S MasterSession -X next; sleep 5s; done"

fi
