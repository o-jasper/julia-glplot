
echo testing $1

julia $1.j > result/$1

cd result 

DATE=`date +%s`

TMP_DIR=/tmp/julia_some_test/$DATE$1/

mkdir $TMP_DIR -p

echo $1 $USER" `git status |wc -l` `git log |head -n 1` time $DATE `wc -l $1`" > $TMP_DIR$1

cat run_list >> $TMP_DIR$1 
mv $TMP_DIR$1 run_list

head -n 1 run_list
