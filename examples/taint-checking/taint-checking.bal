import ballerina/mysql;

//The @sensitive annotation can be used with parameters
//of user-defined functions and actions. This allows users
//to restrict passing untrusted (tainted) data into a security
//sensitive parameter.
function userDefinedSecureOperation (@sensitive string secureParameter) {

}

type Student {
     string firstname,
};


function main (string... args) {
    endpoint mysql:Client customerDatabase {
        host: "localhost",
        port: 3306,
        name: "testdb",
        username: "root",
        password: "root",
        poolOptions: {maximumPoolSize:5}
    };

    //Sensitive parameters of operations built in to Ballerina
    //carry the @sensitive annotation. This ensures that tainted data
    //cannot be passed into them.
    //
    //For example, the taint checking mechanism of Ballerina completely
    //prevents SQL injection vulnerabilities by disallowing 
    //tainted data in the SQL query.
    //
    //This line results in a compiler error as the query 
    //is appended with a user-provided argument.
    table dataTable = check customerDatabase ->
        select("SELECT firstname FROM student WHERE registration_id = " +
               args[0], null, null);

    //This line results in a compiler error as a user-provided
    //argument is passed to a sensitive parameter.
    userDefinedSecureOperation(args[0]);

    if (isInteger(args[0])) {
        //After performing the necessary validations and/or escaping, 
        //the 'untaint' unary expression can be used to mark
        //the proceeding value as untainted and pass it to a sensitive parameter.
        userDefinedSecureOperation(untaint args[0]);
    } else {
        error err = {message:"Validation error: ID should be an integer"};
        throw err;
    }

    while (dataTable.hasNext()) {
        var jsonData = check < Student > dataTable.getNext();
        //The return values of certain functions and actions built-in to Ballerina
        //carry the @tainted annotation to denote that the return value
        //should be considered as untrusted (tainted). One such example
        //is the data read from a database.
        //
        //This line results in a compiler error as a value derived
        //from a database read (tainted) is passed to a sensitive parameter.
        userDefinedSecureOperation(jsonData.firstname);

        string sanitizedData1 = sanitizeAndReturnTainted(jsonData.firstname);
        //This line results in a compiler error as the 'sanitize'
        //function returns a value derived from tainted data. Therefore,
        //the return of the 'sanitize' function is also tainted.
        userDefinedSecureOperation(sanitizedData1);

        string sanitizedData2 = sanitizeAndReturnUntainted(jsonData.firstname);
        //This line successfully compiles. Although the 'sanitize'
        //function returns a value derived from tainted data, the return
        //value is annotated with "@untainted" annotation. This means 
        //the return value is safe and can be considered as trusted.
        userDefinedSecureOperation(sanitizedData2);
    }
    var closeStatus = customerDatabase -> close();
    return;
}

function sanitizeAndReturnTainted (string input) returns string {
    Regex reg = {pattern:"[^a-zA-Z]"};
    return check input.replaceAllWithRegex(reg, "");
}

//The "@untainted" annotation denotes that the return value of
//the function should be considered as trusted (untainted)
//even though the return value is derived from tainted data.
function sanitizeAndReturnUntainted (string input) returns @untainted string {
    Regex reg = {pattern:"[^a-zA-Z]"};
    return check input.replaceAllWithRegex(reg, "");
}

function isInteger (string input) returns boolean {
    Regex reg = {pattern:"\\d+"};
    boolean isInteger = check input.matchesWithRegex(reg);
    return isInteger;
}
