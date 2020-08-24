//
//  VaporEngineRTM.swift
//
// Copyright © 2017 Peter Zignego. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#if os(Linux) || os(macOS) && !COCOAPODS
import Foundation
import NIO
import WebSocketKit

// Builds with *Swift Package Manager ONLY*
public class VaporEngineRTM: RTMWebSocket {

    private let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    // Delegate
    public weak var delegate: RTMDelegate?
    // Websocket
    private var websocket: WebSocket?

    public required init() {}

    public func connect(url: URL) {
        _ = WebSocket.connect(to: url, on: eventLoopGroup) { socket in
            self.didConnect(websocket: socket)
        }
    }

    func didConnect(websocket: WebSocket) {
        self.websocket = websocket

        delegate?.didConnect()

        websocket.onText { ws, text in
            self.delegate?.receivedMessage(text)
        }
        _ = websocket.onClose.always { _ in
            self.delegate?.disconnected()
        }
    }

    public func disconnect() {
        _ = websocket?.close()
        websocket = nil
    }

    public func sendMessage(_ message: String) throws {
        guard let websocket = websocket else { throw SlackError.rtmConnectionError }
        websocket.send(message)
    }
}
#endif
