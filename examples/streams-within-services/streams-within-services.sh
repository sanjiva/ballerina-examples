# At the command line, navigate to the directory that contains the
# `streams-within-services.bal` file and run the `ballerina run` command.
$ ballerina run streams-within-services.bal
ballerina: initiating service(s) in 'streams-within-services.bal'
ballerina: started HTTP/WS endpoint 0.0.0.0:9090

# If the number of requests from the same host is greater than six, a log would print like
ALERT!! : Received more than 6 requests within 5 second from the host: localhost:9090
