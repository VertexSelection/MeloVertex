//
//  DSUServer.swift
//
//  Multi-source Cemuhook-compatible DSU server.
//  Created by MediaMoots on 5/17/2025.
//
//

import Foundation
import CocoaAsyncSocket         // ‹GCDAsyncUdpSocket›
import zlib                     // CRC-32

//──────────────────────────────────────────────────────────────────────── MARK:- DSU Motion protocol

/// One motion source == one DSU *slot* (0-7).
protocol DSUMotionProvider: AnyObject {
    var slot: UInt8                { get }        // unique, 0-7
    var mac:  [UInt8]              { get }        // 6-byte ID
    var connectionType: UInt8      { get }        // 0 = USB, 2 = BT
    var batteryLevel:   UInt8      { get }        // 0-5 (Cemuhook)
    
    func nextSample() -> DSUMotionSample?
}

/// Raw motion payload returned by providers.
struct DSUMotionSample {
    var timestampUS: UInt64        // µs
    var accel: SIMD3<Float>        // G's
    var gyroDeg: SIMD3<Float>      // °/s
}

//──────────────────────────────────────────────────────────────────────── MARK:- Server constants

private enum C {
    static let port: UInt16                 = 26_760
    static let protocolVersion: UInt16      = 1_001
    static let headerMagic                  = "DSUS"
}

//──────────────────────────────────────────────────────────────────────── MARK:- Server core

final class DSUServer: NSObject {

    // Singleton for convenience
    static let shared = DSUServer()
    private override init() {
        serverID = UInt32.random(in: .min ... .max)
        super.init()
        configureSocket()
    }

    // MARK: Public API ─────────────────────────────────────────────
    func register(_ provider: DSUMotionProvider)  { providers[provider.slot] = provider }
    func unregister(slot: UInt8)                  { providers.removeValue(forKey: slot) }

    ///  🔸 providers push fresh samples here.
    func pushSample(_ sample: DSUMotionSample, from provider: DSUMotionProvider) {
        guard let addr = lastClientAddress else { return }      // no subscriber → drop
        sendPadData(sample: sample, from: provider, to: addr)
    }

    // MARK: Private
    private let serverID:           UInt32
    private var socket:             GCDAsyncUdpSocket?
    private var lastClientAddress:  Data?

    private var providers = [UInt8 : DSUMotionProvider]()    // slot→provider
    private var packetNumber = [UInt8 : UInt32]()            // per-slot counter

    // ───────── UDP setup
    private func configureSocket() {
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: .main)
        do {
            try socket?.bind(toPort: C.port)
            try socket?.beginReceiving()
            //print("🟢 DSU server listening on UDP \(C.port)")
        } catch {
            //print("❌ DSU socket error:", error)
        }
    }
}

//──────────────────────────────────────────────────────────────────────── MARK:- UDP delegate

extension DSUServer: GCDAsyncUdpSocketDelegate {

    func udpSocket(_ sock: GCDAsyncUdpSocket,
                   didReceive data: Data,
                   fromAddress addr: Data,
                   withFilterContext ctx: Any?) {

        lastClientAddress = addr

        // Light validation
        guard data.count >= 20,
              String(decoding: data[0..<4], as: UTF8.self) == C.headerMagic,
              data.readUInt16LE(at: 4) == C.protocolVersion
        else { return }

        let type = data.readUInt32LE(at: 16)
        switch type {
        case 0x100001: sendPortInfo(to: addr)   // client asks for port list
        case 0x100002: break                    // subscription acknowledged
        default:       break
        }
    }

    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError err: Error?) {
        //print("UDP closed:", err?.localizedDescription ?? "nil")
        lastClientAddress = nil
    }
}

//──────────────────────────────────────────────────────────────────────── MARK:- Packet helpers

private extension DSUServer {

    // ── Header (16 bytes)
    func appendHeader(into d: inout Data, payloadSize: UInt16) {
        d.append(C.headerMagic.data(using: .utf8)!)   // "DSUS"
        d.append(C.protocolVersion.leData)            // Protocol Version
        d.append(payloadSize.leData)                  // Payload Size
        d.append(Data(repeating: 0, count: 4))        // CRC-stub
        d.append(serverID.leData)                     // Server ID
    }
    func patchCRC32(of packet: inout Data) {
        let crc = packet.withUnsafeBytes { ptr in
            crc32(0, ptr.baseAddress, uInt(packet.count))
        }.littleEndian
        let crcLE = UInt32(crc).littleEndian
        let crcData = withUnsafeBytes(of: crcLE) { Data($0) }
        packet.replaceSubrange(8..<12, with: crcData)
    }

    // ── 0x100001  DSUSPortInfo
    func sendPortInfo(to addr: Data) {
        for p in providers.values {
            var pkt = Data()
            appendHeader(into: &pkt, payloadSize: 12)
            pkt.append(UInt32(0x100001).leData)

            pkt.append(p.slot)
            pkt.append(UInt8(2))              // connected
            pkt.append(UInt8(2))              // full gyro
            pkt.append(p.connectionType)
            pkt.append(p.mac, count: 6)
            pkt.append(p.batteryLevel)
            pkt.append(UInt8(0))              // padding

            patchCRC32(of: &pkt)
            socket?.send(pkt, toAddress: addr, withTimeout: -1, tag: 0)
        }
    }

    // ── 0x100002  DSUSPadDataRsp
    func sendPadData(sample s: DSUMotionSample,
                     from p: DSUMotionProvider,
                     to addr: Data) {

        var pkt = Data()
        appendHeader(into: &pkt, payloadSize: 84)
        pkt.append(UInt32(0x100002).leData)

        pkt.append(p.slot)
        pkt.append(UInt8(2))              // connected
        pkt.append(UInt8(2))              // full gyro
        pkt.append(p.connectionType)
        pkt.append(p.mac, count: 6)
        pkt.append(p.batteryLevel)
        pkt.append(UInt8(1))              // is connected

        let num = packetNumber[p.slot, default: 0]
        pkt.append(num.leData)
        packetNumber[p.slot] = num &+ 1

        pkt.append(UInt16(0).leData)      // buttons
        pkt.append(contentsOf: [0,0])     // HOME / Touch
        pkt.append(contentsOf: [128,128,128,128])    // sticks
        pkt.append(Data(repeating: 0, count: 12))    // d-pad / face / trig
        pkt.append(Data(repeating: 0, count: 12))    // touch 1 & 2
        pkt.append(s.timestampUS.leData)

        pkt.append(s.accel.x.leData)
        pkt.append(s.accel.y.leData)
        pkt.append(s.accel.z.leData)

        pkt.append(s.gyroDeg.x.leData)
        pkt.append(s.gyroDeg.y.leData)
        pkt.append(s.gyroDeg.z.leData)

        patchCRC32(of: &pkt)
        socket?.send(pkt, toAddress: addr, withTimeout: -1, tag: 0)
    }
}

//──────────────────────────────────────────────────────────────────────── MARK:- Helper funcs / ext

private extension FixedWidthInteger {
    var leData: Data {
        var v = self.littleEndian
        return Data(bytes: &v, count: MemoryLayout<Self>.size)
    }
}
private extension Float {
    var leData: Data {
        var v = self
        return Data(bytes: &v, count: MemoryLayout<Self>.size)
    }
}
private extension Data {
    func readUInt16LE(at offset: Int) -> UInt16 {
        self[offset..<offset+2].withUnsafeBytes { $0.load(as: UInt16.self) }.littleEndian
    }
    func readUInt32LE(at offset: Int) -> UInt32 {
        self[offset..<offset+4].withUnsafeBytes { $0.load(as: UInt32.self) }.littleEndian
    }
}
