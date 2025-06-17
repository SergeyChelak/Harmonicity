//
//  MidiInputService.swift
//  Harmonicity
//
//  Created by Sergey on 28.05.2025.
//

import CoreMIDI
import Foundation

enum MidiInputServiceError: Error {
    case clientSetupFailed(OSStatus)
    case inputPortSetupFailed(OSStatus)
}

final class MidiInputService {
    private static let log = logger(category: "MidiInputService")
    
    private var midiClient = MIDIClientRef()
    private var midiInputPort = MIDIPortRef()
    private let commandCenter: MidiCommandCenter
    
    init(_ commandCenter: MidiCommandCenter) {
        self.commandCenter = commandCenter
    }
    
    func setup() throws {
        try setupMIDIClient()
        try setupMIDIInputPort()
        findAndConnectMIDISources()
    }
        
    private func setupMIDIClient() throws {
        let clientName = "MIDIKeyboardReaderClient" as CFString
        let status = MIDIClientCreateWithBlock(clientName, &midiClient) { [weak self] notification in
            guard let self else {
                return
            }
            let messageId = notification.pointee.messageID
            switch messageId {
            case .msgObjectAdded:
                Self.log.info("MIDI Object Added. Re-enumerating sources.")
                self.findAndConnectMIDISources()
            case .msgObjectRemoved:
                Self.log.info("MIDI Object Removed. Re-enumerating sources.")
                self.findAndConnectMIDISources()
            default:
                break
            }
        }
        guard status == noErr else {
            throw MidiInputServiceError.clientSetupFailed(status)
        }
    }
    
    /// Sets up the CoreMIDI input port to receive messages.
    private func setupMIDIInputPort() throws {
        let portName = "MIDIKeyboardInputPort" as CFString
        let status = MIDIInputPortCreateWithBlock(midiClient, portName, &midiInputPort) { [weak self] packetList, srcConnRefCon in
            guard let self else {
                return
            }
            self.processMIDIPacketList(packetList: packetList)
        }
        guard status == noErr else {
            throw MidiInputServiceError.inputPortSetupFailed(status)
        }
    }
    
    /// Finds all available MIDI sources (e.g., keyboards) and connects them to the input port.
    private func findAndConnectMIDISources() {
        let numberOfSources = MIDIGetNumberOfSources()
        Self.log.info("Found \(numberOfSources) MIDI sources.")
        
        for i in 0..<numberOfSources {
            let source = MIDIGetSource(i)
            var displayName: Unmanaged<CFString>?
            let status = MIDIObjectGetStringProperty(source, kMIDIPropertyDisplayName, &displayName)
            
            if status == noErr, let name = displayName?.takeRetainedValue() {
                Self.log.debug("Connecting to MIDI Source: \(name)")
                let connectStatus = MIDIPortConnectSource(midiInputPort, source, nil)
                if connectStatus != noErr {
                    Self.log.error("Error connecting to source \(name): \(connectStatus)")
                }
            } else {
                Self.log.debug("Could not get display name for source \(i)")
            }
        }
    }
    
    // MARK: - MIDI Message Processing
    
    /// Processes a `MIDIPacketList` received from a MIDI source.
    /// This function iterates through each packet and then each byte in the packet to interpret MIDI messages.
    private func processMIDIPacketList(packetList: UnsafePointer<MIDIPacketList>) {
        let packets = packetList.pointee
        var currentPacket = packets.packet
        
        for _ in 0..<packets.numPackets {
            processMIDIPacket(packet: currentPacket)
            currentPacket = MIDIPacketNext(&currentPacket).pointee
        }
    }
    
    /// Processes a single `MIDIPacket`.
    /// This function extracts MIDI messages from the packet data.
    private func processMIDIPacket(packet: MIDIPacket) {
        let data = Mirror(reflecting: packet.data)
            .children
            .map { $0.value as! UInt8 }
        // The actual number of bytes in the packet is `packet.length`.
        let midiBytes = data[0..<Int(packet.length)]
        
        // MIDI messages can be multi-byte. We need to parse them sequentially.
        var i = 0
        while i < midiBytes.count {
            let statusByte = midiBytes[i]
            let channel = statusByte & 0x0F // Get channel from status byte (lower 4 bits)
            let messageType = statusByte & 0xF0 // Get message type (upper 4 bits)
            
            switch messageType {
            case 0x90: // Note On (0x90-0x9F for channels 0-15)
                if i + 2 < midiBytes.count {
                    let note = midiBytes[i + 1]
                    let velocity = midiBytes[i + 2]
                    commandCenter.on(note: note, velocity: velocity, channel: channel)
                    i += 3 // Note On/Off messages are 3 bytes
                } else {
                    Self.log.warning("Incomplete Note On/Off message.")
                    i += 1 // Move to next byte to avoid infinite loop
                }
            case 0x80: // Note Off (0x80-0x8F for channels 0-15)
                if i + 2 < midiBytes.count {
                    let note = midiBytes[i + 1]
                    let velocity = midiBytes[i + 2]
                    commandCenter.off(note: note, velocity: velocity, channel: channel)
                    i += 3
                } else {
                    Self.log.warning("Incomplete Note Off message.")
                    i += 1
                }
            case 0xB0: // Control Change (0xB0-0xBF for channels 0-15)
                if i + 2 < midiBytes.count {
                    let controllerNumber = midiBytes[i + 1]
                    let controllerValue = midiBytes[i + 2]
                    commandCenter.controlChange(control: controllerNumber, value: controllerValue, channel: channel)
                    i += 3
                } else {
                    Self.log.warning("Incomplete Control Change message.")
                    i += 1
                }
            case 0xC0: // Program Change (0xC0-0xCF for channels 0-15)
                if i + 1 < midiBytes.count {
                    let programNumber = midiBytes[i + 1]
                    Self.log.info("Program Change: Channel \(channel), Program \(programNumber)")
                    i += 2
                } else {
                    Self.log.warning("Incomplete Program Change message.")
                    i += 1
                }
            case 0xE0: // Pitch Bend (0xE0-0xEF for channels 0-15)
                if i + 2 < midiBytes.count {
                    let lsb = midiBytes[i + 1]
                    let msb = midiBytes[i + 2]
                    let pitchBendValue = (UInt16(msb) << 7) | UInt16(lsb) // Combine LSB and MSB
                    Self.log.info("Pitch Bend: Channel \(channel), Value \(pitchBendValue)")
                    i += 3
                } else {
                    Self.log.warning("Incomplete Pitch Bend message.")
                    i += 1
                }
            case 0xF0: // System Exclusive (SysEx) or other System Common Messages
                // SysEx messages can be variable length. We need to find the 0xF7 (End of SysEx) byte.
                if statusByte == 0xF0 { // Start of SysEx
                    var sysExData: [UInt8] = []
                    var j = i + 1
                    while j < midiBytes.count && midiBytes[j] != 0xF7 {
                        sysExData.append(midiBytes[j])
                        j += 1
                    }
                    if j < midiBytes.count && midiBytes[j] == 0xF7 {
                        Self.log.info("SysEx Message: \(sysExData.map { String(format: "%02X", $0) }.joined(separator: " "))")
                        i = j + 1 // Move past 0xF7
                    } else {
                        Self.log.warning("Incomplete SysEx message (missing 0xF7).")
                        i += 1 // Move to next byte to avoid infinite loop
                    }
                } else if statusByte == 0xF1 { // MIDI Time Code Quarter Frame
                    if i + 1 < midiBytes.count {
                        Self.log.info("MIDI Time Code Quarter Frame: \(midiBytes[i+1])")
                        i += 2
                    } else {
                        Self.log.warning("Incomplete MIDI Time Code Quarter Frame.")
                        i += 1
                    }
                } else if statusByte == 0xF2 { // Song Position Pointer
                    if i + 2 < midiBytes.count {
                        let lsb = midiBytes[i + 1]
                        let msb = midiBytes[i + 2]
                        let songPosition = (UInt16(msb) << 7) | UInt16(lsb)
                        Self.log.info("Song Position Pointer: \(songPosition)")
                        i += 3
                    } else {
                        Self.log.warning("Incomplete Song Position Pointer.")
                        i += 1
                    }
                } else if statusByte == 0xF3 { // Song Select
                    if i + 1 < midiBytes.count {
                        Self.log.info("Song Select: \(midiBytes[i+1])")
                        i += 2
                    } else {
                        Self.log.warning("Incomplete Song Select.")
                        i += 1
                    }
                } else if statusByte == 0xF6 { // Tune Request
                    Self.log.info("Tune Request")
                    i += 1
                } else if statusByte == 0xF8 { // Timing Clock
                    Self.log.info("Timing Clock")
                    i += 1
                } else if statusByte == 0xFA { // Start
                    Self.log.info("Start")
                    i += 1
                } else if statusByte == 0xFB { // Continue
                    Self.log.info("Continue")
                    i += 1
                } else if statusByte == 0xFC { // Stop
                    Self.log.info("Stop")
                    i += 1
                } else if statusByte == 0xFE { // Active Sensing
                    Self.log.info("Active Sensing")
                    i += 1
                } else if statusByte == 0xFF { // Reset
                    Self.log.info("Reset")
                    i += 1
                } else {
                    Self.log.warning("Unknown System Common/Real-Time Message: \(String(format: "0x%02X", statusByte))")
                    i += 1
                }
            default:
                // Handle unknown status bytes or running status
                Self.log.warning("Unknown MIDI message or running status byte: \(String(format: "0x%02X", statusByte))")
                i += 1
            }
        }
    }
    
    /// Cleans up CoreMIDI resources when the manager is deallocated.
    deinit {
        MIDIPortDispose(midiInputPort)
        MIDIClientDispose(midiClient)
    }
}
