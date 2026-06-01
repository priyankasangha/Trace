import SwiftUI
import MapKit

struct InlineLocationPicker: View {
    @ObservedObject var searchService: LocationSearchService
    
    // Parent Schema Context Targets
    @Binding var locationName: String
    @Binding var latitudeString: String
    @Binding var longitudeString: String
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack {
            TextField("Search for places or landmarks...", text: $searchService.searchQuery)
                .textFieldStyle(.plain)
                .focused($isTextFieldFocused)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(6)
                .fineLineBorder()
            
            if !searchService.searchQuery.isEmpty {
                Button(action: {
                    searchService.searchQuery = ""
                    locationName = ""
                    latitudeString = ""
                    longitudeString = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.6))
                }
                .buttonStyle(.plain)
                .padding(.trailing, 4)
            }
        }
        // ─── POP OVERLAY SOLUTION ───
        .popover(isPresented: Binding(
            get: { isTextFieldFocused && !searchService.completions.isEmpty },
            set: { _ in }
        ), arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(searchService.completions, id: \.self) { completion in
                            Button(action: { selectLocation(completion) }) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(completion.title)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppTheme.primaryText)
                                    if !completion.subtitle.isEmpty {
                                        Text(completion.subtitle)
                                            .font(.system(size: 10))
                                            .foregroundColor(AppTheme.primaryText.opacity(0.5))
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                // Standard system highlight behavior when hover styling matches
                                .background(Color(nsColor: .windowBackgroundColor).opacity(0.001))
                            }
                            .buttonStyle(.plain)
                            
                            Divider().opacity(0.1)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            .frame(width: 320)
            .padding(.vertical, 4)
        }
    }
    
    private func selectLocation(_ completion: MKLocalSearchCompletion) {
        isTextFieldFocused = false
        locationName = completion.title
        searchService.searchQuery = completion.title
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
            
            latitudeString = String(format: "%.5f", coordinate.latitude)
            longitudeString = String(format: "%.5f", coordinate.longitude)
        }
    }
}
