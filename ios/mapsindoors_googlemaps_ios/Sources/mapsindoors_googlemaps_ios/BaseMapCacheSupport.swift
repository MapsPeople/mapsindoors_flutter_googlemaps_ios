import Foundation

/// Whether this build's map provider can cache base-map tiles.
///
/// Google Maps has no offline tile store, so there is nothing to cache base-map tiles into.
///
/// This is a compile-time constant because the iOS SDK offers nothing to ask. `MapProviderBaseMapCache` has no `isBaseMapCachingSupported()`, and both adapters register a provider on map-provider init - Mapbox a real one, Google a no-op - so a non-nil `MPMapsIndoors.baseMapCacheProvider` says nothing about support. Declaring it per provider mirrors Android's `BaseMapCache.kt`, needs no `@_spi` import, and keeps `MapsIndoorsPlugin.swift` identical in both packages.
enum BaseMapCache {
    static let isSupported = false
}
