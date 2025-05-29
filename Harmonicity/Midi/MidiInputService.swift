//
//  MidiInputService.swift
//  Harmonicity
//
//  Created by Sergey on 28.05.2025.
//

import CoreMIDI
import Foundation

final class MidiInputService {
    private var midiClient = MIDIClientRef()
    private var midiInputPort = MIDIPortRef()
    private let commandCenter: MidiCommandCenter
    
    init(_ commandCenter: MidiCommandCenter) {
        self.commandCenter = commandCenter
        setupMIDIClient()
        setupMIDIInputPort()
        findAndConnectMIDISources()
    }
        
    /// Sets up the CoreMIDI client.
    private func setupMIDIClient() {
        let clientName = "MIDIKeyboardReaderClient" as CFString
        let status = MIDIClientCreateWithBlock(clientName, &midiClient) { notification in
            // Handle MIDI notifications (e.g., device added/removed)
            let messageId = notification.pointee.messageID
            switch messageId {
            case .msgObjectAdded:
                print("MIDI Object Added. Re-enumerating sources.")
                self.findAndConnectMIDISources()
            case .msgObjectRemoved:
                print("MIDI Object Removed. Re-enumerating sources.")
                self.findAndConnectMIDISources()
            default:
                break
            }
        }
        
        guard status == noErr else {
            print("Error creating MIDI client: \(status)")
            return
        }
        print("MIDI Client created successfully.")
    }
    
    /// Sets up the CoreMIDI input port to receive messages.
    private func setupMIDIInputPort() {
        let portName = "MIDIKeyboardInputPort" as CFString
        let status = MIDIInputPortCreateWithBlock(midiClient, portName, &midiInputPort) { packetList, srcConnRefCon in
            // This is the MIDIReadBlock where incoming MIDI messages are processed.
            self.processMIDIPacketList(packetList: packetList)
        }
        
        guard status == noErr else {
            print("Error creating MIDI input port: \(status)")
            return
        }
        print("MIDI Input Port created successfully.")
    }
    
    /// Finds all available MIDI sources (e.g., keyboards) and connects them to the input port.
    private func findAndConnectMIDISources() {
        let numberOfSources = MIDIGetNumberOfSources()
        print("Found \(numberOfSources) MIDI sources.")
        
        for i in 0..<numberOfSources {
            let source = MIDIGetSource(i)
            var displayName: Unmanaged<CFString>?
            let status = MIDIObjectGetStringProperty(source, kMIDIPropertyDisplayName, &displayName)
            
            if status == noErr, let name = displayName?.takeRetainedValue() {
                print("Connecting to MIDI Source: \(name)")
                let connectStatus = MIDIPortConnectSource(midiInputPort, source, nil)
                if connectStatus != noErr {
                    print("Error connecting to source \(name): \(connectStatus)")
                }
            } else {
                print("Could not get display name for source \(i)")
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
        let data = Mirror(reflecting: packet.data).children.map { $0.value as! UInt8 }
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
                    if velocity > 0 {
                        print("Note On: Channel \(channel), Note \(note), Velocity \(velocity)")
                        commandCenter.on(note: note, velocity: velocity, channel: channel)
                    } else {
                        // Velocity 0 is often used as Note Off
                        print(">>>>>>>> Note Off: Channel \(channel), Note \(note), Velocity \(velocity) (implicit)")
                        commandCenter.off(note: note, velocity: velocity, channel: channel)
                    }
                    i += 3 // Note On/Off messages are 3 bytes
                } else {
                    print("Incomplete Note On/Off message.")
                    i += 1 // Move to next byte to avoid infinite loop
                }
            case 0x80: // Note Off (0x80-0x8F for channels 0-15)
                if i + 2 < midiBytes.count {
                    let note = midiBytes[i + 1]
                    let velocity = midiBytes[i + 2]
                    print("Note Off: Channel \(channel), Note \(note), Velocity \(velocity)")
                    commandCenter.off(note: note, velocity: velocity, channel: channel)
                    i += 3
                } else {
                    print("Incomplete Note Off message.")
                    i += 1
                }
            case 0xB0: // Control Change (0xB0-0xBF for channels 0-15)
                if i + 2 < midiBytes.count {
                    let controllerNumber = midiBytes[i + 1]
                    let controllerValue = midiBytes[i + 2]
                    print("Control Change: Channel \(channel), Controller \(controllerNumber), Value \(controllerValue)")
                    i += 3
                } else {
                    print("Incomplete Control Change message.")
                    i += 1
                }
            case 0xC0: // Program Change (0xC0-0xCF for channels 0-15)
                if i + 1 < midiBytes.count {
                    let programNumber = midiBytes[i + 1]
                    print("Program Change: Channel \(channel), Program \(programNumber)")
                    i += 2
                } else {
                    print("Incomplete Program Change message.")
                    i += 1
                }
            case 0xE0: // Pitch Bend (0xE0-0xEF for channels 0-15)
                if i + 2 < midiBytes.count {
                    let lsb = midiBytes[i + 1]
                    let msb = midiBytes[i + 2]
                    let pitchBendValue = (UInt16(msb) << 7) | UInt16(lsb) // Combine LSB and MSB
                    print("Pitch Bend: Channel \(channel), Value \(pitchBendValue)")
                    i += 3
                } else {
                    print("Incomplete Pitch Bend message.")
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
                        print("SysEx Message: \(sysExData.map { String(format: "%02X", $0) }.joined(separator: " "))")
                        i = j + 1 // Move past 0xF7
                    } else {
                        print("Incomplete SysEx message (missing 0xF7).")
                        i += 1 // Move to next byte to avoid infinite loop
                    }
                } else if statusByte == 0xF1 { // MIDI Time Code Quarter Frame
                    if i + 1 < midiBytes.count {
                        print("MIDI Time Code Quarter Frame: \(midiBytes[i+1])")
                        i += 2
                    } else {
                        print("Incomplete MIDI Time Code Quarter Frame.")
                        i += 1
                    }
                } else if statusByte == 0xF2 { // Song Position Pointer
                    if i + 2 < midiBytes.count {
                        let lsb = midiBytes[i + 1]
                        let msb = midiBytes[i + 2]
                        let songPosition = (UInt16(msb) << 7) | UInt16(lsb)
                        print("Song Position Pointer: \(songPosition)")
                        i += 3
                    } else {
                        print("Incomplete Song Position Pointer.")
                        i += 1
                    }
                } else if statusByte == 0xF3 { // Song Select
                    if i + 1 < midiBytes.count {
                        print("Song Select: \(midiBytes[i+1])")
                        i += 2
                    } else {
                        print("Incomplete Song Select.")
                        i += 1
                    }
                } else if statusByte == 0xF6 { // Tune Request
                    print("Tune Request")
                    i += 1
                } else if statusByte == 0xF8 { // Timing Clock
                    print("Timing Clock")
                    i += 1
                } else if statusByte == 0xFA { // Start
                    print("Start")
                    i += 1
                } else if statusByte == 0xFB { // Continue
                    print("Continue")
                    i += 1
                } else if statusByte == 0xFC { // Stop
                    print("Stop")
                    i += 1
                } else if statusByte == 0xFE { // Active Sensing
                    print("Active Sensing")
                    i += 1
                } else if statusByte == 0xFF { // Reset
                    print("Reset")
                    i += 1
                } else {
                    print("Unknown System Common/Real-Time Message: \(String(format: "0x%02X", statusByte))")
                    i += 1
                }
            default:
                // Handle unknown status bytes or running status
                print("Unknown MIDI message or running status byte: \(String(format: "0x%02X", statusByte))")
                i += 1
            }
        }
    }
    
    /// Cleans up CoreMIDI resources when the manager is deallocated.
    deinit {
        MIDIPortDispose(midiInputPort)
        MIDIClientDispose(midiClient)
        print("MIDI Client and Port disposed.")
    }
}
