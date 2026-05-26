import SwiftUI

struct ContentView: View {
    @State private var eventName: String = ""
    @State private var eventCategory: String = "Design"
    @State private var statusMessage: String = "Ready to send"
    @State private var isSuccess: Bool = false
    
    let categories = ["Design", "Development", "Feedback", "Bug"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Trace macOS Event Logger")
                .font(.headline)
            
            TextField("Enter event name...", text: $eventName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 250)
            
            Picker("Category", selection: $eventCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category)
                }
            }
            .pickerStyle(PopUpButtonPickerStyle())
            .frame(width: 250)
            
            Button(action: {
                sendEventToBackend()
            }) {
                Text("Send to Node.js Backend")
                    .bold()
                    .padding(.horizontal, 10)
            }
            .disabled(eventName.isEmpty)
            
            Divider()
                .padding(.vertical, 10)
            
            Text(statusMessage)
                .foregroundColor(isSuccess ? .green : .secondary)
                .font(.caption)
        }
        .padding()
        .frame(width: 350, height: 250)
    }
    
    func sendEventToBackend() {
        // Using the direct IPv4 loopback address to your backend on port 3000
        guard let url = URL(string: "http://127.0.0.1:3000/api/events/test-connection") else {
            self.statusMessage = "Invalid URL layout"
            return
        }
        
        let payload: [String: Any] = [
            "name": eventName,
            "category": eventCategory,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            self.statusMessage = "Failed to parse JSON"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        self.statusMessage = "Sending traffic..."
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.isSuccess = false
                    self.statusMessage = "Connection failed: \(error.localizedDescription)"
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                        self.isSuccess = true
                        self.statusMessage = "Success! Logged to trace-backend."
                        self.eventName = "" // Clear the field on success
                    } else {
                        self.isSuccess = false
                        self.statusMessage = "Server returned status code: \(httpResponse.statusCode)"
                    }
                }
            }
        }.resume()
    }
}
