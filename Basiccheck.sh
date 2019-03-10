
#!/bin/bash

#This program checks for memory leaks

#The first and second arguments
dirPath=$1
program=$2

#Tests - "FAIL" as a default value
compilation="FAIL"
memoryLeaks="FAIL"
threadRace="FAIL"

#The return value of the function
testsVal=0

cd $dirPath
make >/dev/null 2>&1
MakefileTrue=$?
#Checks if the path contains "Makefile" and checks if the compilation succeeded
if [ $MakefileTrue -eq 0 ]; then
	compilation=${compilation/FAIL/"PASS"}
	valgrind --tool=memcheck --leak-check=full --error-exitcode=1 -q ./$program >/dev/null 2>&1 
	valgrindTest=$?
	#Checks for memory leaks
	if [ $valgrindTest -ne 3 ]; then
		memoryLeaks=${memoryLeaks/FAIL/"PASS"}
	fi
	valgrind --tool=helgrind --error-exitcode=1 -q ./$program >/dev/null 2>&1
	helgrindTest=$?
	#Checks for thread race
	if [ $helgrindTest -ne 3 ]; then
		threadRace=${threadRace/FAIL/"PASS"}
	fi

fi

#Number between 0-7 that represents the tests that passed or failed
#Compilation test
if [ $compilation == "FAIL" ]; then
	testsVal=$(( $testsVal + 4 ))
fi
#Memory leaks test
if [ $memoryLeaks == "FAIL" ]; then
	testsVal=$(( $testsVal + 2 ))
fi
#Thread race test
if [ $threadRace == "FAIL" ]; then
	testsVal=$(( $testsVal + 1 ))
fi

#Prints to the screen the values of the tests
echo "compilation | memory leaks | thread race"
echo "   " $compilation"        " $memoryLeaks"         " $threadRace  
exit $testsVal
