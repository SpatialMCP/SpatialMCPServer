import Foundation

struct Park: Codable {
  let id: UUID
  let coordinates: Coordinates
  let details: Details
  let distance: Float

  struct Coordinates: Codable {
    let latitude: Float
    let longitude: Float
  }

  struct Details: Codable {
    let name: String
  }
}
