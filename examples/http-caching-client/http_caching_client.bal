import ballerina/http;

endpoint http:Listener proxyEP {
    port:9090
};

endpoint http:Listener backendEP {
    port:8080
};

// HTTP caching is enabled by default for client endpoints. Caching can be disabled by setting `enabled=false` in the
// `cache` config of the client endpoint. In this example, the `isShared` field of the `cacheConfig` is set to true, as the cache
// will be a public cache in this particular scenario. <br>
// The default caching policy is to cache a response only if it contains a `Cache-Control` header and either an
// `ETag` header, or a `Last-Modified` header. The user can control this behaviour by setting the `policy` field of
// the `cacheConfig`. Currently, there are only 2 policies: `CACHE_CONTROL_AND_VALIDATORS` (the default policy) and `RFC_7234`.
endpoint http:Client cachingEP {
    url:"http://localhost:8080",
    cache:{isShared:true}
};

@http:ServiceConfig {basePath:"/cache"}
service cachingProxy bind proxyEP {

    @http:ResourceConfig {
        methods:["GET"],
        path:"/"
    }
    cacheableResource (endpoint caller, http:Request req) {
        http:Request request = new;

        var response = cachingEP -> forward("/hello", req);

        match response {
            http:Response res => {
                // If the request was successful, an HTTP response will be returned.
                // In this example, the received response is forwarded to the client through the outbound endpoint.
                _ = caller -> respond(res);
            }
            http:HttpConnectorError err => {
                // If there was an error, it is used to construct a `500` response, which is sent back to the client.
                http:Response res = new;
                res.statusCode = 500;
                res.setStringPayload(err.message);
                _ = caller -> respond(res);
            }
        }
    }
}

json payload = {"message":"Hello, World!"};

// Sample backend service which serves cacheable responses.
@http:ServiceConfig {basePath:"/hello"}
service helloWorld bind backendEP {

    @http:ResourceConfig {path:"/"}
    sayHello (endpoint caller, http:Request req) {
        http:Response res = new;

        // The `ResponseCacheControl` struct in the `Response` struct can be used for setting the cache control
        // directives associated with the response. In this example, the `maxAge` is set to 15 seconds indicating that the
        // response will be fresh for 15 seconds. The `mustRevalidate` directive instructs that the cache should not
        // serve a stale response without validating it with the origin server first. The public directive is set by
        // setting `isPrivate=false`. This indicates that the response can be cached even by intermediary caches which
        // serve multiple users.
        http:ResponseCacheControl resCC = new;
        resCC.maxAge = 15;
        resCC.mustRevalidate = true;
        resCC.isPrivate = false;

        res.cacheControl = resCC;

        // The `setETag()` function can be used for generating ETags for string, json, xml, and blob types. This uses the
        // `getCRC32()` function from the `security.crypto` package for generating the ETag.
        res.setETag(payload);
        // The `setLastModified()` function sets the current time as the `Last-Modified` header.
        res.setLastModified();

        res.setJsonPayload(payload);
        // When sending the response, if the `cacheControl` field of the response is set, and the user has not already
        // set a `Cache-Control` header, a `Cache-Control` header will be set using the directives set in the `cacheControl`
        // object.
        _ = caller -> respond(res);
    }
}
