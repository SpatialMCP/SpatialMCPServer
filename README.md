<p align="center"><img src="MCP.png" width="128" height="128" /></p>

# SpatialMCPServer

A Swift MCP (Model Context Protocol) server that exposes nearby park data to AI assistants such as Claude Desktop. It acts as a bridge between Claude and a local spatial REST API, enabling real-time park lookups based on GPS coordinates.

## Requirements

- macOS 14+
- Swift 6.3+
- A local park-data REST API running on `http://localhost:8080`

## Getting Started

```bash
# Build
swift build
```

The server communicates over stdio and is designed to be launched by Claude Desktop via its MCP configuration.

## Claude Desktop Integration

Add the server to your Claude Desktop config (`~/Library/Application Support/Claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "spatial-mcp": {
      "command": "/path/to/.build/release/SpatialMCPServer"
    }
  }
}
```

## Backend API

The server expects a REST endpoint at:

```
GET http://localhost:8080/api/v1/parks?latlong={lat,long}&distance={n}&unit={km|mile}
```

Response must be a JSON array of objects with this shape:

```json
[
  {
    "id": "uuid",
    "coordinates": { "latitude": 50.08, "longitude": 14.42 },
    "details": { "name": "Stromovka" },
    "distance": 0.42
  }
]
```
