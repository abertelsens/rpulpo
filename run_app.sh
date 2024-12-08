# shell script to run the application.
# nohup will run the command but keeping it alive if the shell session ends.
# the > /dev/null 2>&1& is sending the output to a nill device. What is does
# is basically to ignore the output. Otherwise the output file will be too heavy
echo "executing command"
echo "puma -p 2948 -e production > /dev/null 2>&1&"
nohup puma -p 2948 -e production > /dev/null 2>&1&
echo "done!"
#puma -p 2948 -e production