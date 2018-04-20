import ballerina/log;
import ballerina/runtime;
import ballerina/io;

function main (string... args) {
    int result;
    //Define the try block to surround the code segment that is likely to throw errors.
    try {
        io:println("Start dividing numbers");
        //An error is thrown when the 'divideNumbers' function is executed.
        result = divideNumbers(1, 0);
        //When an error is thrown, the error type is matched to the clause defined in the catch block and the
        //respective catch block is called. The 'error' type catch clause is structurally equivalent to any error type
        // that is thrown and can be used to catch all errors.

    } catch (error err) {
        io:println("error occurred: " + err.message);

    } finally {
        io:println("finally Block executed");
    }
}

function divideNumbers (int a, int b) returns int {
    return a / b;
}