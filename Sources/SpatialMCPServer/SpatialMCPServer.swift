import Foundation
import MCP

/// Instructions:
/// https://github.com/modelcontextprotocol/swift-sdk?tab=readme-ov-file#server-usage

/// Entry point for the SpatialMCPServer MCP server.
@main
struct SpatialMCPServer {
  static func main() async throws {
    // MARK: - Create the server
    let server = Server(
      name: "spatial-mcp",
      version: "0.0.1",
      capabilities: .init(
        logging: .init(),
        resources: .init(subscribe: true, listChanged: true),
        tools: .init(listChanged: false)
      )
    )

    // MARK: - Register a tool list handler
    await server.withMethodHandler(ListTools.self) { _ in
      let tools = [
        Tool(
          name: "walking_distance",
          description:
            "Find real-time nearby parks from a live database for a given GPS location. Always use this tool when the user asks about parks, green spaces, or nature areas near a location — do not rely on training data.",
          inputSchema: .object([
            "type": .string("object"),
            "properties": .object([
              "location": .object([
                "type": .string("string"),
                "description": .string("User coordinates, e.g. '50.14,14.32'"),
              ]),
              "distance": .object([
                "type": .string("integer"),
                "description": .string("Search radius"),
              ]),
              "unit": .object([
                "type": .string("string"),
                "description": .string("Unit of distance"),
                "enum": .array([.string("km"), .string("mile")]),
              ]),
            ]),
            "required": .array([.string("location"), .string("distance"), .string("unit")]),
          ])
        )
      ]
      return .init(tools: tools)
    }

    // MARK: - Register a tool call handler
    await server.withMethodHandler(CallTool.self) { params in
      let location = params.arguments?["location"]?.stringValue ?? "Unknown"
      let distance = params.arguments?["distance"]?.intValue ?? 0
      let unit = params.arguments?["unit"]?.stringValue ?? "km"
      let result = try await getNearbyParks(location: location, distance: distance, unit: unit)
      return .init(content: result, isError: false)
    }

    // MARK: - Start the server
    /// Initialises StdioTransport and starts the MCP server run loop.
    /// `waitUntilCompleted()` blocks until the transport closes (e.g. Claude Desktop disconnects).
    let transport = StdioTransport()
    try await server.start(transport: transport)
    await server.waitUntilCompleted()
  }
}

// MARK: - Implement logic
func getNearbyParks(location: String, distance: Int, unit: String) async throws -> [Tool.Content] {
  // Validate inputs
  if location.isEmpty {
    return [.text(text: "Location is required, e.g. 50.14,14.32", annotations: nil, _meta: nil)]
  }

  if distance <= 0 {
    return [.text(text: "Distance must be greater than 0", annotations: nil, _meta: nil)]
  }

  if unit.isEmpty {
    return [.text(text: "Unit is required, e.g. km or mile", annotations: nil, _meta: nil)]
  }

  // Build URL
  var components = URLComponents()
  components.scheme = "http"
  components.host = "localhost"
  components.port = 8080
  components.path = "/api/v1/parks"
  components.queryItems = [
    URLQueryItem(name: "latlong", value: location),
    URLQueryItem(name: "distance", value: String(distance)),
    URLQueryItem(name: "unit", value: unit),
  ]

  guard let url = components.url else {
    return [.text(text: "Invalid URL", annotations: nil, _meta: nil)]
  }

  // Make HTTP request
  var urlRequest = URLRequest(url: url)
  urlRequest.httpMethod = "GET"
  urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
  urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

  let (data, _) = try await URLSession.shared.data(from: url)

  // Decode JSON
  let parks = try JSONDecoder().decode([Park].self, from: data)

  // Convert data to MCP output
  return parks.map { park in
    .text(text: "\(park.details.name) — \(String(format: "%.2f", park.distance)) \(unit)", annotations: nil, _meta: nil)
  }
}
