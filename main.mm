//
//  main.cpp
//  curlynk
//
//  Created by juli huang on 5/27/25.
//

#import <iostream>
#import <string>
#import <dispatch/dispatch.h>
#import <Network/Network.h>

using namespace std;

//string dispatch_data_to_string(dispatch_data_t data) {
//    size_t len = dispatch_data_get_size(data);
//    
//    string res(len, '\0');
//    dispatch_data_apply(data, ^bool(dispatch_data_t region, size_t offset, const void *buffer, size_t size) {
//        memcpy(&res[offset], buffer, size);
//        return true;
//        
//    });
//    
//    return res;
//}

string dispatch_data_to_string(dispatch_data_t data) {
    size_t total_size = dispatch_data_get_size(data);
    if (total_size == 0) return "";

    // Use raw buffer
    char* buffer = (char*)malloc(total_size);
    __block size_t offset = 0;

    dispatch_data_apply(data, ^bool(dispatch_data_t region, size_t region_offset, const void *chunk_buffer, size_t size) {
        memcpy(buffer + offset, chunk_buffer, size);
        offset += size;
        return true;
    });

    std::string result(buffer, total_size);
    free(buffer);
    return result;
}


//std::string dispatch_data_to_string(dispatch_data_t data) {
//    const char* buffer = nullptr;
//    size_t size = 0;
//    dispatch_data_t mapped = dispatch_data_create_map(data, (const void**)&buffer, &size);
//    return std::string(buffer, size);
//}


void send_http_req(nw_connection_t con) {
    string request = "GET /todos/1 HTTP/1.1\r\n"
    "Host: apple.com \r\n"
    "Connection: close\r\n"
    "\r\n";
    
    auto request_data = dispatch_data_create(request.c_str(), request.size(), dispatch_get_main_queue(), DISPATCH_DATA_DESTRUCTOR_DEFAULT);
    
    nw_connection_send(con, request_data, NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT, true, ^(nw_error_t send_error) {
        if (send_error != nullptr) {
            exit(EXIT_FAILURE);
        }
    });
    
    
    
}

int main() {
    
    
//    dispatch_queue_t q = dispatch_queue_create("com.example.net work", DISPATCH_QUEUE_SERIAL);
    const char* host = "https://www.apple.com";
    const char* port = "80";
    nw_parameters_t parameters = nw_parameters_create_secure_tcp(NW_PARAMETERS_DEFAULT_CONFIGURATION, NW_PARAMETERS_DEFAULT_CONFIGURATION);
    
    
    //nw_parameters_create_secure_tcp(NW_PARAMETERS_DEFAULT_CONFIGURATION);
    
    
    
    nw_endpoint_t endpt = nw_endpoint_create_host(host, port);
    
    nw_connection_t conn = nw_connection_create(endpt, parameters);
    
    nw_connection_set_state_changed_handler(conn, ^(nw_connection_state_t state, nw_error_t error) {
        switch(state) {
            case nw_connection_state_ready:
                
                send_http_req(conn);
                
            case nw_connection_state_failed:
                exit(EXIT_FAILURE);
                break;
            case nw_connection_state_cancelled:
                exit(EXIT_SUCCESS);
                
            default: break;
        }
    });
    
    nw_connection_set_receive_handler(conn, true, ^(dispatch_data_t content, bool is_complete, nw_error_t error) {
        if (content) {
            std::string response = dispatch_data_to_string(content);
            std::cout << "Received: " << response << std::endl;
        }
        if (is_complete || error != nullptr) {
            nw_connection_cancel(conn);
        }
    });

        
    nw_connection_start(conn);
    
    dispatch_main();
    
    return 0;
        
    
    
}
