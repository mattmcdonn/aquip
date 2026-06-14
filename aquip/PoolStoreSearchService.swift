import Foundation
import CoreLocation
import MapKit
import SwiftUI

// MARK: - Nearby pool store model

struct PoolStoreLocation: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let distanceText: String
    let mapItem: MKMapItem
}

// MARK: - Nearby pool store search service

@Observable
final class PoolStoreSearchService: NSObject, CLLocationManagerDelegate {

    enum LoadState {
        case idle
        case loading
        case available
        case unavailable
    }

    var loadState: LoadState = .idle
    var stores: [PoolStoreLocation] = []
    var message: String = ""

    private let locationManager = CLLocationManager()
    private var hasRequestedSearch = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func start() {
        guard loadState == .idle else { return }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            loadState = .loading
            message = "Requesting location access..."
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            loadState = .loading
            message = "Searching nearby pool stores..."
            locationManager.requestLocation()

        case .denied, .restricted:
            loadState = .unavailable
            message = "No nearby stores could be listed. Check your location settings or internet connection."

        @unknown default:
            loadState = .unavailable
            message = "No nearby stores could be listed. Check your location settings or internet connection."
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard !hasRequestedSearch else { return }

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            hasRequestedSearch = true
            loadState = .loading
            message = "Searching nearby pool stores..."
            manager.requestLocation()

        case .denied, .restricted:
            loadState = .unavailable
            message = "No nearby stores could be listed. Check your location settings or internet connection."

        case .notDetermined:
            break

        @unknown default:
            loadState = .unavailable
            message = "No nearby stores could be listed. Check your location settings or internet connection."
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else {
            loadState = .unavailable
            message = "No nearby stores could be listed. Check your location settings or internet connection."
            return
        }

        searchNearbyStores(from: userLocation)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        loadState = .unavailable
        message = "No nearby stores could be listed. Check your location settings or internet connection."
    }

    // MARK: - Search

    private func searchNearbyStores(from userLocation: CLLocation) {
        Task {
            do {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = "pool supply store"
                request.region = MKCoordinateRegion(
                    center: userLocation.coordinate,
                    latitudinalMeters: 35_000,
                    longitudinalMeters: 35_000
                )

                let response = try await MKLocalSearch(request: request).start()

                let relevantItems = response.mapItems
                    .filter { Self.isRelevantPoolStore($0) && Self.hasPhoneNumber($0) }
                    .prefix(5)

                let mappedStores = relevantItems.map { item in
                    PoolStoreLocation(
                        name: item.name ?? "Pool Store",
                        address: Self.addressText(for: item),
                        distanceText: Self.distanceText(from: userLocation, to: item),
                        mapItem: item
                    )
                }

                await MainActor.run {
                    self.stores = Array(mappedStores)
                    if self.stores.isEmpty {
                        self.loadState = .unavailable
                        self.message = "No relevant nearby pool stores were found. Try searching in Maps for “pool supply store” or check your location/internet settings."
                    } else {
                        self.loadState = .available
                        self.message = ""
                    }
                }
            } catch {
                await MainActor.run {
                    self.stores = []
                    self.loadState = .unavailable
                    self.message = "No nearby stores could be listed. Check your location settings or internet connection."
                }
            }
        }
    }

    private static func hasPhoneNumber(_ item: MKMapItem) -> Bool {
        guard let phone = item.phoneNumber else { return false }
        return !phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private static func isRelevantPoolStore(_ item: MKMapItem) -> Bool {
        let name = item.name?.lowercased() ?? ""
        let phone = item.phoneNumber?.lowercased() ?? ""
        let url = item.url?.absoluteString.lowercased() ?? ""
        let haystack = "\(name) \(phone) \(url)"

        let keywords: [String] = [
            "pool", "pools", "spa", "spas", "hot tub", "hottub",
            "swimming", "water care", "pool supply", "pool supplies"
        ]
        return keywords.contains { haystack.contains($0) }
    }

    private static func addressText(for item: MKMapItem) -> String {
        if let reps = item.addressRepresentations {
            return reps.fullAddress(includingRegion: false, singleLine: true) ?? item.name ?? "Address unavailable"
        }
        return item.name ?? "Address unavailable"
    }

    private static func distanceText(from userLocation: CLLocation, to item: MKMapItem) -> String {
        let meters = userLocation.distance(from: item.location)
        let kilometers = meters / 1000
        if kilometers < 1 {
            return "\(Int(meters.rounded())) m away"
        }
        return String(format: "%.1f km away", kilometers)
    }
}
