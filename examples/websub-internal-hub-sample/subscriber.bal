//Ballerina WebSub Subscriber service, which subscribes to notifications at a Hub.
import ballerina/log;
import ballerina/mime;
import ballerina/http;
import ballerina/websub;

//The endpoint to which the subscriber service is bound.
endpoint websub:Listener websubEP {
    port:8181
};

//Annotations specifying the subscription parameters.
@websub:SubscriberServiceConfig {
    path:"/websub",
    subscribeOnStartUp:true,
    topic: "http://www.websubpubtopic.com",
    hub: "https://localhost:9292/websub/hub",
    leaseSeconds: 3600000,
    secret: "Kslk30SNF2AChs2"
}
service websubSubscriber bind websubEP {

    //Resource accepting intent verification requests.
    onIntentVerification (endpoint caller, websub:IntentVerificationRequest request) {
        //Build the response for the subscription intent verification request that was received.
        http:Response response = request.buildSubscriptionVerificationResponse();
        if (response.statusCode == 202) {
            log:printInfo("Intent verified for subscription request");
        } else {
            log:printWarn("Intent verification denied for subscription request");
        }
        _ = caller->respond(response);
    }

    //Resource accepting content delivery requests.
    onNotification (websub:Notification notification) {
        log:printInfo("WebSub Notification Received: " + notification.payload.toString());
    }

}
