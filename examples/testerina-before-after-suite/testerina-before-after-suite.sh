#At the command line, navigate to the directory that contains the 
#`.bal` file and run the `ballerina test` command.
#Note that you need to have the ballerina-tools distribution 
#installed in order to run this command. 
$ ballerina test testerina-before-after-suite.bal
---------------------------------------------------------------------------
    T E S T S
---------------------------------------------------------------------------
---------------------------------------------------------------------------
Running Tests of Package: .
---------------------------------------------------------------------------
I'm the before suite function!
I'm in test function 1!
I'm in test function 2!
I'm the after suite function!

Tests run: 2, Passed: 2, Failures: 0, Skipped: 0 - in TestSuite


---------------------------------------------------------------------------
Results:

Tests run: 2, Passed: 2, Failures: 0, Skipped: 0
---------------------------------------------------------------------------
Summary:


................................................................... SUCCESS
---------------------------------------------------------------------------
