import SwiftUI
import MapKit
import CoreLocation
import Combine

// ==========================================
// CURRENT LOCATION MANAGER
// ==========================================

class CurrentLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocationCoordinate2D?
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

// ==========================================
// INTERACTIVE MAP LOCATION PICKER
// ==========================================

struct MapLocationPicker: View {
    @ObservedObject var searchService: LocationSearchService
    @Binding var locationName: String
    @Binding var latitudeString: String
    @Binding var longitudeString: String
    
    @StateObject private var locationManager = CurrentLocationManager()
    @State private var mapPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 43.65, longitude: -79.38),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            searchBar
            interactiveMap
            locationSummary
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .onReceive(locationManager.$currentLocation.compactMap { $0 }.first()) { location in
            if selectedCoordinate == nil {
                withAnimation {
                    mapPosition = .region(MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    ))
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.roseGoldDark.opacity(0.6))
            
            TextField("Search for places or landmarks...", text: $searchService.searchQuery)
                .textFieldStyle(.plain)
                .font(AppTheme.body)
                .focused($isSearchFocused)
            
            if !searchService.searchQuery.isEmpty {
                Button(action: clearLocation) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.primaryText.opacity(0.3))
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(AppTheme.primaryText.opacity(0.08), lineWidth: AppTheme.thinLineWidth)
        )
        .popover(isPresented: Binding(
            get: { isSearchFocused && !searchService.completions.isEmpty },
            set: { _ in }
        ), arrowEdge: .bottom) {
            autocompleteResults
        }
    }
    
    private var autocompleteResults: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(searchService.completions, id: \.self) { completion in
                    Button(action: { selectSearchResult(completion) }) {
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
                        .background(Color(nsColor: .windowBackgroundColor).opacity(0.001))
                    }
                    .buttonStyle(.plain)
                    
                    Divider().opacity(0.1)
                }
            }
        }
        .frame(width: 320)
        .frame(maxHeight: 200)
        .padding(.vertical, 4)
    }
    
    private var interactiveMap: some View {
        ZStack(alignment: .bottomTrailing) {
            MapReader { proxy in
                Map(position: $mapPosition) {
                    if let coord = selectedCoordinate {
                        Marker(
                            locationName.isEmpty ? "Selected Location" : locationName,
                            coordinate: coord
                        )
                        .tint(AppTheme.roseGoldDark)
                    }
                }
                .mapStyle(.standard(elevation: .flat))
                .mapControls {
                    MapZoomStepper()
                    MapCompass()
                }
                .onTapGesture(coordinateSpace: .local) { position in
                    if let coordinate = proxy.convert(position, from: .local) {
                        placePin(at: coordinate)
                    }
                }
            }
            
            currentLocationButton
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.primaryText.opacity(0.08), lineWidth: AppTheme.thinLineWidth)
        )
    }
    
    private var currentLocationButton: some View {
        Button(action: centerOnCurrentLocation) {
            Image(systemName: "location.fill")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.roseGoldDark)
                .frame(width: 28, height: 28)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppTheme.primaryText.opacity(0.1), lineWidth: AppTheme.thinLineWidth)
                )
        }
        .buttonStyle(.plain)
        .help("Center on current location")
        .padding(8)
    }
    
    @ViewBuilder
    private var locationSummary: some View {
        if !locationName.isEmpty {
            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.roseGoldDark)
                
                Text(locationName)
                    .font(AppTheme.subtitle)
                    .foregroundColor(AppTheme.primaryText.opacity(0.7))
                    .lineLimit(1)
                
                Spacer()
                
                if !latitudeString.isEmpty {
                    Text("\(latitudeString), \(longitudeString)")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(AppTheme.primaryText.opacity(0.35))
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func placePin(at coordinate: CLLocationCoordinate2D) {
        selectedCoordinate = coordinate
        latitudeString = String(format: "%.5f", coordinate.latitude)
        longitudeString = String(format: "%.5f", coordinate.longitude)
        
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let placemark = placemarks?.first {
                let name = placemark.name
                    ?? placemark.locality
                    ?? "Dropped Pin"
                locationName = name
                searchService.searchQuery = name
            } else {
                locationName = "Dropped Pin"
                searchService.searchQuery = ""
            }
        }
    }
    
    private func selectSearchResult(_ completion: MKLocalSearchCompletion) {
        isSearchFocused = false
        locationName = completion.title
        searchService.searchQuery = completion.title
        
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
            selectedCoordinate = coordinate
            latitudeString = String(format: "%.5f", coordinate.latitude)
            longitudeString = String(format: "%.5f", coordinate.longitude)
            
            withAnimation {
                mapPosition = .region(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))
            }
        }
    }
    
    private func clearLocation() {
        searchService.searchQuery = ""
        locationName = ""
        latitudeString = ""
        longitudeString = ""
        selectedCoordinate = nil
    }
    
    private func centerOnCurrentLocation() {
        if let location = locationManager.currentLocation {
            withAnimation {
                mapPosition = .region(MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                ))
            }
        } else {
            locationManager.requestLocation()
        }
    }
}
