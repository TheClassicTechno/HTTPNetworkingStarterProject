//
//  main.cpp
//  curlynk
//
//  Created by juli huang on 5/27/25.
//

#import <iostream>
#import <string>
//#import <cstring>
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
    char request[] = "GET / HTTP/1.1\r\nHost: apple.com\r\n\r\n";
    
    auto request_data = dispatch_data_create(request, strlen(request), dispatch_get_main_queue(), DISPATCH_DATA_DESTRUCTOR_DEFAULT);
    
    nw_connection_send(con, request_data, NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT, true, ^(nw_error_t send_error) {
        if (send_error != nullptr) {
            exit(EXIT_FAILURE);
        }
    });
    
    
    
}

void receive_http_response(nw_connection_t con){
    nw_connection_receive(con, 1, 4096, ^(dispatch_data_t content, nw_content_context_t context, bool isComplete, nw_error_t error){
        if(content){
            const void* buffer;
            size_t size;
            dispatch_data_create_map(content, &buffer, &size);
            string response(reinterpret_cast<const char*>(buffer), size);
            cout<<"=== HTTP response ===\n"<<response<<"\n";
        }
        
        if(isComplete){
            cout<<"===response complete===\n";
            nw_connection_cancel(con);
            exit(0);
        }
        
        if(error){
            cerr<<"receive error:"<<nw_error_get_error_code(error)<<"\n";
        }else{
            receive_http_response(con);
        }
        
        
    });
}

int main() {
    
    
//    dispatch_queue_t q = dispatch_queue_create("com.example.net work", DISPATCH_QUEUE_SERIAL);
    const char* host = "http://apple.com:80";
    nw_parameters_t parameters = nw_parameters_create_secure_tcp(NW_PARAMETERS_DISABLE_PROTOCOL, NW_PARAMETERS_DEFAULT_CONFIGURATION);
    
    
    //nw_parameters_create_secure_tcp(NW_PARAMETERS_DEFAULT_CONFIGURATION);
    
    dispatch_queue_t dispatch = dispatch_queue_create("queue", nullptr);
    
   // w_endpoint_t endpt = nw_endpoint_create_host(host, port);
    nw_endpoint_t endpt = nw_endpoint_create_url(host);
    
    nw_connection_t conn = nw_connection_create(endpt, parameters);
    
    nw_connection_set_queue(conn, dispatch);
    
    nw_connection_set_state_changed_handler(conn, ^(nw_connection_state_t state, nw_error_t error) {
        switch(state) {
            case nw_connection_state_ready: {
                
                send_http_req(conn);
                receive_http_response(conn);
                break;
                
            }
                
            case nw_connection_state_failed: {
                exit(EXIT_FAILURE);
                break;
            }
            case nw_connection_state_cancelled:
                exit(EXIT_SUCCESS);
                
                
            default: break;
        }
    });
    
//   nw_connection_group_set_receive_handler(<#nw_connection_group_t  _Nonnull group#>, <#uint32_t maximum_message_size#>, <#bool reject_oversized_messages#>, <#^(dispatch_data_t  _Nullable content, nw_content_context_t  _Nonnull context, bool is_complete)receive_handler#>)
    // receive incoming data
//    nw_connection_group_set_receive_handler(conn, 100000, true, ^(dispatch_data_t content, bool is_complete, nw_error_t error) {
//        if (content) {
//            std::string response = dispatch_data_to_string(content);
//            std::cout << "Received: " << response << std::endl;
//        }
//        if (is_complete || error != nullptr) {
//            nw_connection_cancel(conn);
//        }
//    });

   
        
        
    nw_connection_start(conn);
    
    //dispatch_main();
    sleep(1000);
    return 0;
        
    
    
}
