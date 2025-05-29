import Foundation
import Network

// Converts DispatchData to a String
func dispatchDataToString(_ data: DispatchData) -> String {
    var result = ""
    data.enumerateBytes { buffer, _, _ in
        if let string = String(data: buffer, encoding: .utf8) {
            result += string
        }
    }
    return result
}

// Sends an HTTP GET request
func sendHTTPRequest(connection: NWConnection) {
    let request = "GET / HTTP/1.1\r\nHost: apple.com\r\nConnection: close\r\n\r\n"
    let requestData = request.data(using: .utf8)!

    connection.send(content: requestData, completion: .contentProcessed { sendError in
        if let error = sendError {
            print("Send error: \(error)")
            exit(EXIT_FAILURE)
        }
    })
}

// Receives the HTTP response
func receiveHTTPResponse(connection: NWConnection) {
    connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { data, _, isComplete, error in
        if let data = data, !data.isEmpty {
            let response = dispatchDataToString(data)
            print("=== HTTP Response ===")
            print(response)
        }

        if let error = error {
            print("Receive error: \(error)")
        }

        if isComplete {
            print("=== Response complete ===")
            connection.cancel()
            exit(EXIT_SUCCESS)
        } else {
            receiveHTTPResponse(connection: connection)
        }
    }
}

// Main execution
let host = NWEndpoint.Host("apple.com")
let port = NWEndpoint.Port("80")!

let parameters = NWParameters.tcp
let connection = NWConnection(host: host, port: port, using: parameters)

connection.stateUpdateHandler = { state in
    switch state {
    case .ready:
        print("Connection ready")
        sendHTTPRequest(connection: connection)
        receiveHTTPResponse(connection: connection)
    case .failed(let error):
        print("Connection failed: \(error)")
        exit(EXIT_FAILURE)
    case .cancelled:
        print("Connection cancelled")
        exit(EXIT_SUCCESS)
    default:
        break
    }
}

connection.start(queue: .main)

dispatchMain()
