// Created by juli huang on 5/28/25.

import Foundation
import Network

/// Sends an HTTP GET request over the given connection.
func sendHTTPRequest(on connection: NWConnection) {
    let requestString = """
    GET / HTTP/1.1\r\n
    Host: www.apple.com\r\n
    Connection: close\r\n
    \r\n
    """
    guard let requestData = requestString.data(using: .utf8) else {
        
        return
    }
    connection.send(content: requestData, completion: .contentProcessed { error in
        if let error = error {
            
            exit(EXIT_FAILURE)
        }
    })
}

/// Recursively receives chunks of Data until the connection is closed.
func receiveHTTPResponse(on connection: NWConnection) {
    connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { data, _, isComplete, error in
        if let error = error {
            
            exit(EXIT_FAILURE)
        }
        if let data = data, !data.isEmpty {
            // Convert the Data chunk directly into a String
            if let text = String(data: data, encoding: .utf8) {
                print(text, terminator: "")
            } else {
                print("cant decode chunk")
            }
        }
        if isComplete {
           
            connection.cancel()
            exit(EXIT_SUCCESS)
        } else {
            // Keep reading more data
            receiveHTTPResponse(connection: connection)
        }
    }
}
func makeParams(useTLS: Bool)->NWParameters{
  if useTLS {
    let tls = NWProtocolTLS.Options()
    return NWParameters(tls: tls, tcp: NWProtocolTCP.Options())
  }
  else {
    return NWParameters.tcp
  }
}
func main() {
    let useTLS: Bool = true
    let hostS = "www.apple.com"
    let port = NWEndpoint.Port(443)
    let params=makeParams(useTLS: useTLS)
    let end = NWEndpoint.hostPort(host: .init(hostS), port: port) 
    let connection = NWConnection(to: end, using: params)
  
    connection.stateUpdateHandler = { (state:NWConnection.State) in
        switch state {
        case .waiting(let error):
            print("connection error: \(error)")
        case .ready:
          
            sendHTTPRequest(on: connection)
            receiveHTTPResponse(on: connection)
        case .failed(let error):
          
            exit(EXIT_FAILURE)
        case .cancelled:
           
            exit(EXIT_SUCCESS)
        default:
            break
        }
    }

    connection.start(queue: .main)
    dispatchMain()  // keeps the process alive for callbacks
}

main()
