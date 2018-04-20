// This is client implementation for unary blocking scenario
import ballerina/io;
import ballerina/grpc;

function main (string... args) {
    // Client endpoint configuration
    endpoint HelloWorldBlockingClient helloWorldBlockingEp {
        host:"localhost",
        port:9090
    };

    //Working with custom headers
    grpc:Headers headers = new;
    headers.setEntry("x-id", "0987654321");

    // Executing unary blocking call
    (string, grpc:Headers)|error unionResp = helloWorldBlockingEp -> hello("WSO2", headers);
    match unionResp {
        (string, grpc:Headers) payload => {
            string result;
            grpc:Headers resHeaders;
            (result, resHeaders) = payload;
            io:println("Client Got Response : ");
            io:println(payload);
            string headerValue = resHeaders.get("x-id") but {() => "none"};
            io:println("Headers: " + headerValue);
        }
        error err => {
            io:println("Error from Connector: " + err.message);
        }
    }
}
