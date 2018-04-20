import ballerina/config;
import ballerina/http;
import ballerina/test;

boolean serviceStarted;

function startService(){
    config:setConfig("b7a.users.tom.password", "password1");
    config:setConfig("b7a.users.tom.scopes", "scope2,scope3");
    config:setConfig("b7a.users.dick.password", "password2");
    config:setConfig("b7a.users.dick.scopes", "scope1");
    serviceStarted = test:startServices("secured-hello-world-service-with-basic-auth");
}

@test:Config {
    enable:false,
    before:"startService",
    after:"stopService"
}
function testFunc() {
    // Chck whether the server is started
    test:assertTrue(serviceStarted, msg = "Unable to start the service");
    testAuthSuccess();
    testAuthnFailure();
    testAuthzFailure();
}

function testAuthSuccess () {
    // create client
    endpoint http:Client httpEndpoint { targets:[{ url:"http://localhost:9090" }],
        auth: {scheme:"basic", username:"tom", password:"password1"} };
    http:Request req = new;
    // Send a GET request to the specified endpoint
    var response = httpEndpoint -> get("/hello/sayHello", req);
    match response {
        http:Response resp => {
            test:assertEquals(resp.statusCode, 200, msg = "Expected status code 200 not received");
        }
        http:HttpConnectorError err => test:assertFail(msg = "Failed to call the endpoint:");
    }
}

function testAuthnFailure () {
    // create client
    endpoint http:Client httpEndpoint { targets:[{ url:"http://localhost:9090" }],
        auth: {scheme:"basic", username:"tom", password:"password"} };
    http:Request req = new;
    // Send a GET request to the specified endpoint
    var response = httpEndpoint -> get("/hello/sayHello", req);
    match response {
        http:Response resp => {
            test:assertEquals(resp.statusCode, 401, msg = "Expected status code 401 not received");
        }
        http:HttpConnectorError err => test:assertFail(msg = "Failed to call the endpoint:");
    }
}

function testAuthzFailure () {
    // create client
    endpoint http:Client httpEndpoint { targets:[{ url:"http://localhost:9090" }],
        auth: {scheme:"basic", username:"dick", password:"password2"} };
    http:Request req = new;
    // Send a GET request to the specified endpoint
    var response = httpEndpoint -> get("/hello/sayHello", req);
    match response {
        http:Response resp => {
            test:assertEquals(resp.statusCode, 403, msg = "Expected status code 403 not received");
        }
        http:HttpConnectorError err => test:assertFail(msg = "Failed to call the endpoint:");
    }
}

function stopService(){
    test:stopServices("secured-hello-world-service-with-basic-auth");
}
