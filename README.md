# HTTPNetworkingStarterProject

just some starter apps I made to refresh my memory on http and networking concepts:)

# project description
3 in 1 project, all doing HTTP get responses and printing out headers, body, status code, etc, but using different APIs and languages (Swift, Objective C, C++)

# key phrases learned
PlaygroundPage.current.needsIndefiniteExecution = true 
Prevents playground from quitting too early

Create shared task
perform network requests (like GET or POST) asynchronously in Swift.

key: The header name (e.g. "Content-Type", "Date", "Server")
value: The header value (e.g. "application/json", "Mon, 27 May 2025 10:00:00 GMT")

converts raw byte data into a readable string

line is used to stop the main run loop in a macOS or iOS application, usually in non-UI contexts like command-line tools or unit tests.

What does task resume do?
It starts the network task if it hasn’t started yet.
Or resumes the task if it was previously suspended.
Without calling resume, the task will not start and no network request happens.

An autorelease pool is a mechanism used in Objective-C to manage the memory of objects that are sent an autoreleasemessage. It helps automatically release objects at a later time, avoiding memory leaks without requiring you to manually release every object immediately.
