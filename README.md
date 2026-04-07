<p align="center"><img src="MCP.png" width="128" height="128" /></p>

# SpatialMCPServer

A Swift MCP (Model Context Protocol) server that exposes nearby park data to AI assistants such as Claude Desktop. It acts as a bridge between Claude and a local spatial REST API, enabling real-time park lookups based on GPS coordinates.

Article can be read [here](https://medium.com/@kicsipixel/from-coordinates-to-conversations-an-mcp-server-for-spatial-data-2649707814a6).

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

The server expects:

```
curl "http://localhost:8080/api/v1/parks?latlong=50.0867,14.4122&distance=1&unit=km"
```

Response is a JSON array of objects:

```json
[
  {
    "distance": 0.9509209,
    "coordinates": {
      "latitude": 50.094017,
      "longitude": 14.407415
    },
    "details": {
      "name": "Chotkovy sady_MCP"
    },
    "id": "F088BF04-B21B-4506-8385-7505252A4DDB"
  },
  {
    "distance": 0.49082246,
    "coordinates": {
      "longitude": 14.408254,
      "latitude": 50.088776
    },
    "details": {
      "name": "Vojanovy sady_MCP"
    },
    "id": "DEEE7B74-546A-465B-86B4-874262465624"
  }
]
```
