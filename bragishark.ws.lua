--[[
Copyright 2020 Tasos Sahanidis

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--
bragi_proto = Proto("bragi", "CUE Bragi protocol")

local commands = {
    [0x01] = "Set Property",
    [0x02] = "Get Property",
    [0x05] = "Close handle",
    [0x06] = "Begin Write",
    [0x07] = "Continue Write",
    [0x08] = "Read chunk",
    [0x09] = "Probe resource", -- This has to be a probe function, because it happens before a read/write.
    [0x0d] = "Open handle",
    [0x12] = "Ping"
}

-- FIXME
local req_status = {
    [0x00] = "Success",
    [0x01] = "ERROR: Unknown", -- CUE doesn't seem to ask for the resource again after this. It also doesn't close the handle, so it has to be an error.
    [0x03] = "ERROR: Handle already open", -- possibly?
}

-- Temporarily stores the last property that was requested from the device
-- Key format: "1.2", with the last part being chopped off as that's the endpoint
local bragi_get_queue = {}

-- Stores the property requested given a frame
local bragi_get_queue_frame = {}

local properties = {
    [0x01] = "Pollrate",
    [0x03] = "Mode",
    [0x0d] = "Automatic Sleep Enabled",
    [0x0e] = "Automatic Sleep Timeout",
    [0x0f] = "Battery Level",
    [0x10] = "Battery Status",
    [0x11] = "USB VID",
    [0x12] = "USB PID",
    [0x13] = "APP FW Version",
    [0x14] = "BLD FW Version",
    [0x15] = "Wireless Chip FW Version",
    [0x36] = "Connected Subdevice Bitfield", -- fwiw CUE calls this a bitmap
    [0x41] = "Hardware Layout",
    [0x44] = "Brightness Level Index",
    [0x45] = "WinLock Enabled",
    [0x4a] = "WinLock Disabled Shortcuts",
    [0x5f] = "MultipointConnectionSupport",
}

-- USB IDs
local vendor_ids = {
    [0x1b1c] = "Corsair"
}

local product_ids = {
    [0x1b62] = "K57 RGB Wireless Dongle",
    [0x1b6e] = "K57 RGB Wireless",
}
--[[
local layout_types = {
    [0x00] = "ANSI",
    [0x01] = "ISO",
    [0x02] = "ABNT",
    [0x03] = "JIS",
    [0x04] = "Dubeolsik"
}]]--

local f = bragi_proto.fields

f.vid = ProtoField.uint16("bragi.vid", "Vendor ID", base.HEX, vendor_ids)
f.pid = ProtoField.uint16("bragi.pid", "Product ID", base.HEX, product_ids)

-- Root commands
f.cmd = ProtoField.uint8("bragi.command", "Command", base.HEX, commands)

-- Properties
f.property = ProtoField.uint8("bragi.property", "Property", base.HEX, properties)

f.req_status = ProtoField.uint8("bragi.req_status", "Status", base.HEX, req_status)

-- Property tables
local prop_mode = {
    [0x01] = "Hardware",
    [0x02] = "Software",
}
f.prop_mode = ProtoField.uint8("bragi.prop_mode", "Mode", base.HEX, prop_mode)

local prop_pollrate = {
    [0x01] = "8 ms",
    [0x02] = "4 ms",
    [0x03] = "2 ms",
    [0x04] = "1 ms",
}
f.prop_pollrate = ProtoField.uint8("bragi.prop_pollrate", "Pollrate", base.HEX, prop_pollrate)

local prop_hwlayout = {
    [0x02] = "ISO" -- This might be wrong
}
f.prop_hwlayout = ProtoField.uint8("bragi.prop_hwlayout", "Hardware Layout", base.HEX, prop_hwlayout)

local prop_batterystatus = {
    [0x01] = "Charging",
    [0x02] = "Full",
    [0x03] = "Charging",
}
f.prop_batterystatus = ProtoField.uint8("bragi.prop_batterystatus", "Battery Status", base.HEX, prop_batterystatus)

f.brightness = ProtoField.uint8("bragi.brightness", "Brightness Level Index", base.HEX)
f.prop_sleep_timeout = ProtoField.relative_time("bragi.sleep_timeout", "Sleep Timeout")
f.prop_sleep_timeout_enabled = ProtoField.bool("bragi.prop_sleep_timeout_enabled", "Sleep Timeout Enabled")

-- Resource IDs used to get handles
local resources = {
    [0x01] = "Lighting",
    [0x05] = "Pairing ID",
}
f.resource = ProtoField.uint8("bragi.resource", "Resource ID", base.HEX, resources)
f.handle = ProtoField.uint8("bragi.handle", "Handle ID", base.HEX)

-- Payload
f.length = ProtoField.uint32("bragi.length", "Length")
f.payload = ProtoField.bytes("bragi.payload", "Payload")

-- Unknown
f.unknown = ProtoField.uint8("bragi.unknown", "Unknown", base.HEX)

-- Bragi first byte
-- 0...3 -> target device. 0 is the current device that we're talking to
-- 4     -> Seems set when direction is OUT. Seems odd that the direction is in the packet itself though.
-- 5...8 -> Unknown
f.header = ProtoField.uint8("bragi.header", "Header", base.HEX)
f.target = ProtoField.uint8("bragi.target", "Target device", base.DEC, NULL, 0x7)
local t_direction = {
    [0x00] = "IN",
    [0x01] = "OUT",
}
f.direction = ProtoField.uint8("bragi.direction", "Direction", base.DEC, t_direction, 0x8)

-- subdevice bitfield definitions
f.sub = ProtoField.uint8("bragi.subdev", "Subdevice Bitfield", base.HEX)
f.sub0 = ProtoField.bool("bragi.subdev.0", "Subdevice 0 (unused)", 8, NULL, 0x1)
f.sub1 = ProtoField.bool("bragi.subdev.1", "Subdevice 1", 8, NULL, 0x2)
f.sub2 = ProtoField.bool("bragi.subdev.2", "Subdevice 2", 8, NULL, 0x4)
f.sub3 = ProtoField.bool("bragi.subdev.3", "Subdevice 3", 8, NULL, 0x8)
f.sub4 = ProtoField.bool("bragi.subdev.4", "Subdevice 4", 8, NULL, 0x10)
f.sub5 = ProtoField.bool("bragi.subdev.5", "Subdevice 5", 8, NULL, 0x20)
f.sub6 = ProtoField.bool("bragi.subdev.6", "Subdevice 6", 8, NULL, 0x40)
f.sub7 = ProtoField.bool("bragi.subdev.7", "Subdevice 7", 8, NULL, 0x80)

f.extra_hid = ProtoField.bytes("bragi.extra_hid", "Extra HID")
f.hid = ProtoField.bytes("bragi.hid", "HID")

-- Used to get the packet direction
--urb_dir_f = Field.new("usb.endpoint_address.direction")
-- Above doesn't work for usbip
urb_src_f = Field.new("usb.src")
urb_dst_f = Field.new("usb.dst")
frame_no_f = Field.new("frame.number")

-- Helper functions
function table_to_string(tab, cmd)
    local strcmd = tab[cmd]
    if strcmd == nil then
        return "Unknown"
    end
    return strcmd
end

-- Removes the last .Z from X.Y.Z
function usbstr_strip_endpoint(usbstr)
    return usbstr:gsub("(.*)%..*$","%1")
end


-- Reset the state
function bragi_proto.init()
    bragi_get_queue = {}
    bragi_get_queue_frame = {}
end

-- Not so great function that parses a property name and adds it to the tree
function parse_property(t_bragi, pinfo, property, buffer, offset)
    local value = buffer(offset, 1)
    local valueint = value:uint()
    local valuestr = "Unknown"
    local skip_offset = 1
    local showvalue = true
    if property == 0x01 then -- pollrate
        t_bragi:add(f.prop_pollrate, value)
        valuestr = table_to_string(prop_pollrate, valueint)
    elseif property == 0x03 then -- mode
        t_bragi:add(f.prop_mode, value)
        valuestr = table_to_string(prop_mode, valueint)
    elseif property == 0x11 then -- vid
        value = buffer(offset, 2)
        valueint = value:le_uint()
        t_bragi:add_le(f.vid, value)
        valuestr = table_to_string(vendor_ids, valueint)
        skip_offset = 2
    elseif property == 0x12 then -- pid
        value = buffer(offset, 2)
        valueint = value:le_uint()
        t_bragi:add_le(f.pid, value)
        valuestr = table_to_string(product_ids, valueint)
        skip_offset = 2
    elseif property == 0x10 then -- battery status
        t_bragi:add(f.prop_batterystatus, value)
        valuestr = table_to_string(prop_batterystatus, valueint)
    elseif property == 0x44 then -- brightness
        t_bragi:add(f.brightness, value)
        valuestr = tostring(valueint)
    elseif property == 0x0e then -- sleep delay
        -- Only 3 bytes are used (max 99 minutes), but we'll assume it's a uint32 for convenience
        value = buffer(offset, 4)
        valueint = value:le_uint()
        
        -- Convert ms to ns and s
        local s  = (valueint / 1000)
        local ns = (valueint % 1000) * 1000000
        
        local nstime = NSTime.new(s, ns)
        t_bragi:add(f.prop_sleep_timeout, value, nstime)
        valuestr = tostring(valueint) .. " ms"
        skip_offset = 4
    elseif property == 0x0d then -- sleep delay enabled
        t_bragi:add(f.prop_sleep_timeout_enabled, value)
        valuestr = value:uint()
    elseif property == 0x36 then -- subdevice bitfield
        showvalue = false
        local bitf = t_bragi:add(f.sub, value)
        bitf:add(f.sub0, value)
        bitf:add(f.sub1, value)
        bitf:add(f.sub2, value)
        bitf:add(f.sub3, value)
        bitf:add(f.sub4, value)
        bitf:add(f.sub5, value)
        bitf:add(f.sub6, value)
        bitf:add(f.sub7, value)
    end
    if showvalue then
        pinfo.cols["info"]:append(" = " .. valuestr)
    end
    -- We don't need the offset anymore after we're done with this function
    --return skip_offset
end

function bragi_proto.dissector(buffer, pinfo, tree)
    local urb_src = urb_src_f().value
    local urb_dst = urb_dst_f().value
    local urb_dir = 1
    local urb_ep_str = urb_src
    if urb_src == "host" then
        urb_dir = 0
        urb_ep_str = urb_dst
    end

    local urb_ep_num = tonumber(string.match(urb_ep_str, "%d+%.%d+%.(%d+)"))

    -- Bragi packets are 64 bytes long, except for HID input which is 16
    if buffer:len() ~= 64 and (buffer:len() ~= 16 and urb_ep_num ~= 1 and urb_dir ~= 1) then
        return
    end


    local frame_no = frame_no_f().value

    pinfo.cols["protocol"] = "Bragi"

    local t_bragi = tree:add(bragi_proto, buffer())

    if urb_dir == 1 and urb_ep_num == 3 then
        pinfo.cols["info"] = "Bragi extra key input"
        t_bragi:add(f.extra_hid, buffer())
        return
    end

    if urb_dir == 1 and urb_ep_num == 1 then
        pinfo.cols["info"] = "Bragi HID input"
        t_bragi:add(f.hid, buffer())
        return
    end

    local offset = 0
    local firstbyte = buffer(offset, 1)
    local targetint = bit.band(firstbyte:uint(), 0x07)
    local header = t_bragi:add(f.header, firstbyte)
    header:add(f.target, firstbyte)
    header:add(f.direction, firstbyte)
    offset = offset + 1

    local command = buffer(offset, 1)
    t_bragi:add(f.cmd, command)
    command = command:uint()
    offset = offset + 1

    pinfo.cols["info"] = "Dev " .. tostring(targetint) .. ": " .. table_to_string(commands, command)
    if urb_dir == 0 then -- Request
        pinfo.cols["info"]:append(" Request")

        if command == 0x01 or command == 0x02 then -- Set/Get
            local property = buffer(offset, 1)
            offset = offset + 2
            t_bragi:add(f.property, property)
            property = property:uint()

            pinfo.cols["info"]:append(" " .. table_to_string(properties, property))
            if command == 0x02 and pinfo.visited == false then
                bragi_get_queue[usbstr_strip_endpoint(urb_dst)] = property
            elseif command == 0x01 then
                parse_property(t_bragi, pinfo, property, buffer, offset)
            end
        elseif command == 0x0d then -- Open handle
            local handle = buffer(offset, 1)
            offset = offset + 1
            
            t_bragi:add(f.handle, handle)
            
            local resource = buffer(offset, 1)
            t_bragi:add(f.resource, resource)
            --offset = offset + 1
            
            pinfo.cols["info"]:append(" for " .. table_to_string(resources, resource:uint()) .. " on handle " .. tostring(handle:uint()))
        elseif command == 0x05 then -- Close handle
            local unknown = buffer(offset, 1)
            offset = offset + 1
            t_bragi:add(f.unknown, unknown)
            
            local handle = buffer(offset, 1)
            offset = offset + 1
            t_bragi:add(f.handle, handle)
            pinfo.cols["info"]:append(" for handle " .. tostring(handle:uint()))
        elseif command == 0x06 then -- Begin write
            local handle = buffer(offset, 1)
            offset = offset + 1
            t_bragi:add(f.handle, handle)
            pinfo.cols["info"]:append(" for handle " .. tostring(handle:uint()))
            
            local length = buffer(offset, 4)
            offset = offset + 4
            t_bragi:add_le(f.length, length)
            
            local payload = buffer(offset)
            t_bragi:add(f.payload, payload)
        elseif command == 0x07 then -- Continue write
            local handle = buffer(offset, 1)
            offset = offset + 1
            t_bragi:add(f.handle, handle)
            pinfo.cols["info"]:append(" for handle " .. tostring(handle:uint()))
            
            local payload = buffer(offset)
            t_bragi:add(f.payload, payload)
        end
    else -- Response
        pinfo.cols["info"]:append(" Response")
        
        local status = buffer(offset, 1)
        t_bragi:add(f.req_status, status)
        status = status:uint()
        pinfo.cols["info"]:append(" " .. table_to_string(req_status, status))
        if status ~= 0x00 then
            return
        end

        offset = offset + 1
        if command == 0x02 then
            if bragi_get_queue_frame[frame_no] == nil then
                local usbstr = usbstr_strip_endpoint(urb_src)
                local property = bragi_get_queue[usbstr]
                bragi_get_queue_frame[frame_no] = property
                bragi_get_queue[usbstr] = nil
            end
            local property = bragi_get_queue_frame[frame_no]
            t_bragi:add(f.property, bragi_get_queue_frame[frame_no])
            pinfo.cols["info"]:append(" (" .. table_to_string(properties, property))
            parse_property(t_bragi, pinfo, property, buffer, offset)
            pinfo.cols["info"]:append(")")
        elseif command == 0x09 then -- Probe
            offset = offset + 1
            offset = offset + 1
            -- Start of length field
            local length = buffer(offset, 4)
            t_bragi:add_le(f.length, length)
        end
    end
end

usb_table = DissectorTable.get("usb.interrupt")
usb_table:add(0x03, bragi_proto)
usb_table:add(0xffff, bragi_proto)
