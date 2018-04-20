import ballerina/test;
import ballerina/io;

boolean serviceStarted;

function startService(){
    serviceStarted = test:startServices("http-disable-chunking");
}

@test:Config {
    before:"startService",
    after:"stopService"
}
function testFunc() {
    // Invoking the main function.
    endpoint http:Client httpEndpoint { targets:[{ url:"http://localhost:9092" }] };
    // Checking whether the server is started.
    test:assertTrue(serviceStarted, msg = "Unable to start the service");

    json response1 = {"Outbound request content":"Lenght-18"};

    http:Request req = new;
    // Sending a GET request to the specified endpoint.
    var response = httpEndpoint -> get("/chunkingSample", req);
    match response {
        http:Response resp => {
            var res = check resp.getJsonPayload();
            test:assertEquals(res, response1);
        }
        http:HttpConnectorError err => test:assertFail(msg = "Failed to call the endpoint:");
    }
}

function stopService(){
    test:stopServices("http-disable-chunking");
}
