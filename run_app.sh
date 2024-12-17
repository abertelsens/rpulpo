# shell script to run the application.
# nohup will run the command but keeping it alive if the shell session ends.
# the > /dev/null 2>&1& is sending the output to a nill device. What is does
# is basically to ignore the output. Otherwise the output file will be too heavy
# for more info see:
# https://stackoverflow.com/questions/10408816/how-do-i-use-the-nohup-command-without-getting-nohup-out

echo "pulpo: executing command"
echo "puma -p 2948 -e production > /dev/null 2>&1&"
nohup puma -p 2948 -e production > /dev/null 2>&1&
echo "done!"
#puma -p 2948 -e production