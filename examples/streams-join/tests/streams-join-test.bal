import ballerina/test;
import ballerina/io;

boolean serviceStarted;

function startService(){
    serviceStarted = test:startServices("streams-join");
}

@test:Config {
    before:"startService",
    after:"stopService"
}
function testFunc() {
    // Invoking the main function
    endpoint http:Client httpEndpoint { targets:[{ url:"http://localhost:9090" }] };
    // Chck whether the server is started
    test:assertTrue(serviceStarted, msg = "Unable to start the service");

    json clientResp1 = {"message" : "Raw material request successfully received"};
    json clientResp2 = {"message":"Production input request successfully received"};

    http:Request req = new;
    req.setJsonPayload({"name":"Teak","amount":1000.0});
    // Send a GET request to the specified endpoint
    var response = httpEndpoint -> post("/rawmaterial", req);
    match response {
        http:Response resp => {
            var res = check resp.getJsonPayload();
            test:assertEquals(res, clientResp1);
        }
        http:HttpConnectorError err => test:assertFail(msg = "Failed to call the endpoint:");
    }

    http:Request req2 = new;
    req2.setJsonPayload({"name":"Teak","amount":500.0});
    // Send a GET request to the specified endpoint
    var response2 = httpEndpoint -> post("/productionmaterial", req);
    match response2 {
        http:Response resp => {
            var res = check resp.getJsonPayload();
            test:assertEquals(res, clientResp2);
        }
        http:HttpConnectorError err => test:assertFail(msg = "Failed to call the endpoint:");
    }
}

function stopService(){
    test:stopServices("streams-join");
}