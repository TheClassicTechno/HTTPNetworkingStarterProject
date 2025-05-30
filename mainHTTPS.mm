#include <iostream>
#include <string>
#include <dispatch/dispatch.h>
#include <Network/Network.h>

using namespace std;

// Converts dispatch_data_t to std::string
string dispatch_data_to_string(dispatch_data_t data) {
    size_t total_size = dispatch_data_get_size(data);
    if (total_size == 0) return "";

    char* buffer = (char*)malloc(total_size);
    __block size_t offset = 0;

    dispatch_data_apply(data, ^bool(dispatch_data_t region, size_t region_offset, const void* chunk, size_t size) {
        memcpy(buffer + offset, chunk, size);
        offset += size;
        return true;
    });

    string result(buffer, total_size);
    free(buffer);
    return result;
}

// Sends a basic GET request
void send_http_req(nw_connection_t con, const string& host) {
    string req = "GET / HTTP/1.1\r\n"
                 "Host: " + host + "\r\n"
                 "Connection: close\r\n\r\n";

    cout << "[→] Sending request:\n" << req << endl;

    dispatch_data_t request_data = dispatch_data_create(
        req.c_str(),
        req.size(),
        dispatch_get_main_queue(),
        DISPATCH_DATA_DESTRUCTOR_DEFAULT
    );

    nw_connection_send(con, request_data, NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT, true,
                       ^(nw_error_t send_error) {
        if (send_error) {
            cerr << "[!] Send error: " << nw_error_get_error_string(send_error) << endl;
            exit(EXIT_FAILURE);
        }
    });
}

// Recursively receives response chunks
void receive_response(nw_connection_t conn) {
    nw_connection_receive(conn, 1, 65536,
        ^(dispatch_data_t content, nw_content_context_t context, bool is_complete, nw_error_t receive_error) {
            if (receive_error) {
                cerr << "[!] Receive error: " << nw_error_get_error_string(receive_error) << endl;
                exit(EXIT_FAILURE);
            }

            if (content) {
                string body = dispatch_data_to_string(content);
                cout << "[←] Received chunk (" << body.size() << " bytes):\n"
                     << body << endl;
            }

            if (is_complete) {
                cout << "[✓] Response complete, cancelling connection.\n";
                nw_connection_cancel(conn);
                exit(EXIT_SUCCESS);
            } else {
                receive_response(conn);  // continue recursively
            }
        }
    );
}

// Main entry
int main() {
    bool useTLS = true;
    const string host = "apple.com";
    const char* portCStr = useTLS ? "443" : "80";

    // Parameters: enable TLS or plain TCP
    nw_parameters_t parameters = nw_parameters_create_secure_tcp(
        useTLS ? NW_PARAMETERS_DEFAULT_CONFIGURATION : NW_PARAMETERS_DISABLE_PROTOCOL,
        NW_PARAMETERS_DEFAULT_CONFIGURATION
    );

    nw_endpoint_t endpoint = nw_endpoint_create_host(host.c_str(), portCStr);
    nw_connection_t conn = nw_connection_create(endpoint, parameters);

    dispatch_queue_t q = dispatch_queue_create("curlynk.queue", nullptr);
    nw_connection_set_queue(conn, q);

    // Connection state handler
    nw_connection_set_state_changed_handler(conn,
        ^(nw_connection_state_t state, nw_error_t error) {
            switch (state) {
                case nw_connection_state_ready:
                    cout << "[*] Connection ready (" << (useTLS ? "HTTPS" : "HTTP") << ")\n";
                    send_http_req(conn, host);
                    receive_response(conn);
                    break;

                case nw_connection_state_failed:
                    cerr << "[!] Connection failed: " << nw_error_get_error_string(error) << endl;
                    exit(EXIT_FAILURE);

                case nw_connection_state_cancelled:
                    cout << "[*] Connection cancelled\n";
                    exit(EXIT_SUCCESS);

                default:
                    break;
            }
        }
    );

    nw_connection_start(conn);
    cout << "[*] Started connection, entering dispatch loop...\n";
    dispatch_main(); // Keeps the app running for async callbacks
    return 0;
}
