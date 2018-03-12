cue_proto = Proto("cue", "Corsair Utility Engine protocol")

local commands = {
    [0x01] = "HID Event",
    [0x02] = "Media Key Event",
    [0x03] = "Corsair HID Event",
    [0x07] = "Write",
    [0x0e] = "Read",
    [0x7f] = "Write Multiple",
    [0xff] = "Read Multiple"
}

local subcommands = {
    [0x01] = "Identification",
    [0x02] = "Reset",
    [0x04] = "Special Function Control",
    [0x05] = "Lighting Control",
    [0x0a] = "Change Poll Rate",
    [0x0c] = "Start Firmware Update",
    [0x0d] = "Firmware Update Data Position",
    [0x13] = "Mouse Specific",
    [0x14] = "Static Keyboard Profile",
    [0x15] = "Mouse Profile GUID",
    [0x16] = "Mouse Profile Name",
    [0x17] = "Dynamic Keyboard Profile",
    [0x22] = "Mouse Colour Change",
    [0x25] = "Zoned Colour Change",
    [0x27] = "9-bit Colour Change",
    [0x28] = "24-bit Colour Change",
    [0x40] = "Key Input Mode"
}

local reset_types = {
    [0x00] = "Medium Reset",
    [0x01] = "Fast Reset",
    [0xaa] = "Reboot to Bootloader",
    [0xf0] = "Slow Reset"
}

local control_types = {
    [0x01] = "Hardware",
    [0x02] = "Software"
}

local colour_types = {
    [0x01] = "Red",
    [0x02] = "Green",
    [0x03] = "Blue"
}

local vendor_ids = {
    [0x1b1c] = "Corsair"
}

local product_ids = {
    [0x1b3d] = "K55 RGB",
    [0x1b40] = "K63",
    [0x1b17] = "K65 RGB",
    [0x1b07] = "K65",
    [0x1b37] = "K65 LUX RGB",
    [0x1b39] = "K65 RAPIDFIRE",
    [0x1b3f] = "K68",
    [0x1b4f] = "K68 RGB",
    [0x1b13] = "K70 RGB",
    [0x1b09] = "K70",
    [0x1b33] = "K70 LUX RGB",
    [0x1b36] = "K70 LUX",
    [0x1b38] = "K70 RAPIDFIRE RGB",
    [0x1b3a] = "K70 RAPIDFIRE",
    [0x1b11] = "K95 RGB",
    [0x1b08] = "K95",
    [0x1b2d] = "K95 PLATINUM RGB",
    [0x1b20] = "STRAFE RGB",
    [0x1b15] = "STRAFE",
    [0x1b44] = "STRAFE",
    [0x1b12] = "M65 RGB",
    [0x1b2e] = "M65 PRO RGB",
    [0x1b14] = "SABRE RGB", 
    [0x1b19] = "SABRE RGB", 
    [0x1b2f] = "SABRE RGB", 
    [0x1b32] = "SABRE RGB", 
    [0x1b1e] = "SCIMITAR RGB",
    [0x1b3e] = "SCIMITAR PRO RGB",
    [0x1b3c] = "HARPOON RGB",
    [0x1b34] = "GLAIVE RGB",
    [0x1b22] = "KATAR",
    [0x1b35] = "DARK CORE RGB",
    [0x1b3b] = "MM800 RGB POLARIS",
    [0x1b2a] = "VOID RGB"
}

local device_types = {
    [0xc0] = "Keyboard",
    [0xc1] = "Mouse",
    [0xc2] = "Mousepad"
}

local layout_types = {
    [0x00] = "ANSI",
    [0x01] = "ISO",
    [0x02] = "ABNT",
    [0x03] = "JIS"
}

local f = cue_proto.fields

-- Root commands
f.cmd = ProtoField.uint8("cue.command", "Command", base.HEX, commands)

-- Subcommands
f.subcmd = ProtoField.uint8("cue.subcommand", "Subcommand", base.HEX, subcommands)

-- Reset Subcommands
f.reset_type = ProtoField.uint8("cue.reset.type", "Reset Type", base.HEX, reset_types)

-- Control Subcommands
f.special_mode = ProtoField.uint8("cue.special_function.mode", "Special Function Control Mode", base.DEC, control_types)
f.lighting_mode = ProtoField.uint8("cue.lighting.mode", "Lighting Control Mode", base.DEC, control_types)

-- Colour Subcommands
f.colour_type = ProtoField.uint8("cue.colour.type", "Colour Type", base.DEC, colour_types)

-- Firmware Update
f.fwupdate_position = ProtoField.uint8("cue.fwupdate.position", "Firmware Update Data Position", base.DEC)

-- FW identification fields
f.ident_fwver = ProtoField.uint16("cue.ident.fwver", "Firmware Version", base.HEX)
f.ident_bldver = ProtoField.uint16("cue.ident.bldver", "Bootloader Version", base.HEX)
f.ident_vendor = ProtoField.uint16("cue.ident.vendor", "USB Vendor ID", base.HEX, vendor_ids)
f.ident_product = ProtoField.uint16("cue.ident.product", "USB Product ID", base.HEX, product_ids)
f.ident_pollrate = ProtoField.uint8("cue.ident.pollrate", "Poll Rate (msec)", base.DEC)
f.ident_devtype = ProtoField.uint8("cue.ident.device_type", "Device Type", base.HEX, device_types)
f.ident_layout = ProtoField.uint8("cue.ident.layout", "Keyboard Layout", base.HEX, layout_types)

-- Hardware modes
f.profile_guid = ProtoField.bytes("cue.profile.guid", "Profile GUID")

-- Payload fields
f.payload_payload = ProtoField.bytes("cue.payload.payload", "Payload")
f.payload_size = ProtoField.uint8("cue.payload.size", "Payload Size", base.DEC)
f.payload_seqnum = ProtoField.uint8("cue.payload.seqnum", "Payload Sequence Number", base.DEC)

function cue_proto.dissector(buffer, pinfo, tree)
    -- Corsair packets are 64 bytes long.
    if buffer:len() ~= 64 then
        return
    end

    pinfo.cols["protocol"] = "CUE"

    local t_cue = tree:add(cue_proto, buffer())
    local offset = 0

    local command = buffer(offset, 1)
    t_cue:add(f.cmd, command)
    command = command:uint()
    offset = offset + 1
    
    local subcommand = buffer(offset, 1)
    offset = offset + 1

    if command == 0x07 or command == 0x0e then -- Write
        if command == 0x07 then
            pinfo.cols["info"] = "Write"
        else
            pinfo.cols["info"] = "Read"
        end
        t_cue:add(f.subcmd, subcommand)
        subcommand = subcommand:uint()
   
        if subcommand == 0x01 then -- Firmware Identification
            pinfo.cols["info"]:append(" Identification")

            offset = offset + 2

            local fwver = buffer(offset + 4, 2)
            local bldver = buffer(offset + 6, 2)
            local vendor = buffer(offset + 8, 2)
            local product = buffer(offset + 10, 2)
            local pollrate = buffer(offset + 12, 1)
            local devtype = buffer(offset + 16, 1)

            t_cue:add_le(f.ident_fwver, fwver)
            t_cue:add_le(f.ident_bldver, bldver)
            t_cue:add_le(f.ident_vendor, vendor)
            t_cue:add_le(f.ident_product, product)
            t_cue:add_le(f.ident_pollrate, pollrate)
            t_cue:add_le(f.ident_devtype, devtype)

            -- Note for the future: ~= is inequality, not !=
            if vendor:le_uint() ~= 0 and product:le_uint() ~= 0 then
                pinfo.cols["info"]:append(": " .. vendor_ids[vendor:le_uint()] .. " " .. product_ids[product:le_uint()])
            end
            
            -- Keyboard layout
            if devtype:uint() == 0xc0 then
                local layout = buffer(offset + 19, 1)
                t_cue:add_le(f.ident_layout, layout)
                pinfo.cols["info"]:append(" " .. layout_types[layout:uint()])
            end
        
            -- Device type
            if devtype:uint() >= 0xc0 and devtype:uint() <= 0xc2 then
                pinfo.cols["info"]:append(" " .. device_types[devtype:uint()])
            end

        elseif subcommand == 0x02 then -- Reset
            local reset_type = buffer(offset, 1)
            t_cue:add(f.reset_type, reset_type)
            pinfo.cols["info"]:append(" " .. reset_types[reset_type])

        elseif subcommand == 0x04 then -- Special Function
            local control_type = buffer(offset, 1)
            t_cue:add(f.special_mode, control_type)
        
            if control_type:uint() > 2 then
                pinfo.cols["info"]:append(" Special Function Mode to Unknown")
                return
            end
            pinfo.cols["info"]:append(" Special Function Mode to " .. control_types[control_type:uint()])
       
        elseif subcommand == 0x05 then -- Lighting
        
            local control_type = buffer(offset, 1)
            t_cue:add(f.lighting_mode, control_type)
            
            if control_type:uint() > 2 then
                -- TODO: Strafe sidelights?
                --[[if control_type:uint() == 8 then
                    local mode = buffer(offset + 2, 1)
                    if mode:uint() == 0 or mode:uint() == 1 then
                        pinfo.cols["info"]:append(" Sidelight Mode to " .. control_types[mode:uint() + 1])
                        return
                    end
                end]]--
                pinfo.cols["info"]:append(" Lighting Mode to Unknown")
                return
            end

            if control_type:uint() ~= 0x00 then
                pinfo.cols["info"]:append(" Lighting Mode to " .. control_types[control_type:uint()])
            elseif command == 0x0e then
                pinfo.cols["info"]:append(" Init Sync")
            end

        elseif subcommand == 0x0a then -- Change Poll Rate

            local pollrate = buffer(offset + 2, 1)

            pinfo.cols["info"]:append(" Poll Rate")

            -- TODO: Add info to tree.

        elseif subcommand == 0x0c then -- Start Firmware Update

            pinfo.cols["info"]:append(" Start Firmware Update")

            -- TODO: expand this

        elseif subcommand == 0x0d then -- Firmware Update Data Position
            
            local position = buffer(offset + 4, 1)

            pinfo.cols["info"]:append(" Firmware Update Data Position")

            t_cue:add(f.fwupdate_position, position)

            -- TODO: expand this

        elseif subcommand == 0x13 then -- Mouse Specific

            local arg1 = buffer(offset, 1):uint()
            local arg2 = buffer(offset + 1, 1):uint()

            if arg1 == 0x02 then -- DPI
                pinfo.cols["info"]:append(" DPI")

                if arg2 == 0x00 then -- DPI Indicator Mode
                    pinfo.cols["info"]:append(" Indicator Mode")
                elseif arg2 == 0x01 then -- DPI Mode
                    pinfo.cols["info"]:append(" Mode")
                else
                    pinfo.cols["info"]:append(string.format(" Unknown %d", arg2))
                end
            elseif arg1 == 0x03 then -- Lift Height
                pinfo.cols["info"]:append(" Lift Height")

                -- TODO: Lift Height table
            elseif arg1 == 0x05 then -- DPI enabled bitmask
                pinfo.cols["info"]:append(" DPI Enabled Bitmask")

                -- TODO: Show bitmask
            elseif arg1 == 0x06 then -- Mysterious 0x06
                pinfo.cols["info"]:append(" Mysterious 0x06")

                -- TODO: Figure out what this even does
            elseif arg1 == 0x07 then -- Mysterious 0x07
                pinfo.cols["info"]:append(" Mysterious 0x07")

                -- TODO: Likewise
            elseif arg1 == 0x0a then -- Mysterious 0x0A
                pinfo.cols["info"]:append(" Mysterious 0x0A")

                -- TODO: Likewise
            elseif arg1 == 0x0b then -- Mysterious 0x0B
                pinfo.cols["info"]:append(" Mysterious 0x0B")

                -- TODO: Likewise
            elseif arg1 == 0x0c then -- Mysterious 0x0C
                pinfo.cols["info"]:append(" Mysterious 0x0C")

                -- TODO: Likewise
            elseif arg1 >= 0x10 and arg1 < 0x20 then -- Hardware Profile Colour
                local zone = arg1 % 16
                local red = buffer(offset + 3, 1)
                local green = buffer(offset + 4, 1)
                local blue = buffer(offset + 5, 1)

                pinfo.cols["info"]:append(string.format(" Profile %d Colour", zone))
                -- TODO: Add info to tree
            elseif arg1 >= 0xd0 and arg1 < 0xe0 then -- DPI Profile
                local zone = arg1 % 16
                local xdpi = buffer(offset + 4, 2)
                local ydpi = buffer(offset + 6, 2)
                local red = buffer(offset + 8, 1)
                local green = buffer(offset + 9, 1)
                local blue = buffer(offset + 10, 1)

                pinfo.cols["info"]:append(string.format(" DPI Profile %d", zone))
                -- TODO: Likewise.
            else
                pinfo.cols["info"]:append(string.format(" Mouse Unknown %d %d", arg1, arg2))
            end

        elseif subcommand == 0x14 then -- Keyboard Profile

            local proftype = buffer(offset, 1)
            local mode = buffer(offset + 4, 1)
            local colour = buffer(offset + 5, 1)
            
            pinfo.cols["info"]:append(" Keyboard Profile " .. tostring(mode))

            if proftype:uint() == 0x02 then
                pinfo.cols["info"]:append(" 9-bit ")
            elseif proftype:uint() == 0x03 then
                pinfo.cols["info"]:append(" 24-bit ")
            elseif proftype:uint() == 0x04 then
                pinfo.cols["info"]:append(" Side Lighting ")
            else
                pinfo.cols["info"]:append(" Unknown ")
            end

            if proftype:uint() == 0x03 and colour:uint() >= 0x01 and colour:uint() <= 0x03 then
                pinfo.cols["info"]:append(colour_types[colour:uint()])
            end

        elseif subcommand == 0x15 then -- Profile GUID

            local mode = buffer(offset + 1, 1)
            local guid = buffer(offset + 2, 32)

            pinfo.cols["info"]:append(string.format(" Profile %d GUID", mode:uint()))

            -- TODO: Investigate how to give Wireshark UTF16LE.

        elseif subcommand == 0x16 then -- Profile Name

            local mode = buffer(offset + 1, 1)
            local name = buffer(offset + 2, 32)

            pinfo.cols["info"]:append(string.format(" Profile %d Name", mode:uint()))

            -- TODO: Likewise.

        elseif subcommand == 0x17 then -- Dynamic Keyboard Animation

            pinfo.cols["info"]:append(" Animation")

            local arg1 = buffer(offset, 1):uint()
            local arg2 = buffer(offset + 1, 1):uint()

            -- TODO: Add these to the Wireshark tree
            if arg1 == 0x05 then -- New File
                pinfo.cols["info"]:append(" New File")
            elseif arg1 == 0x07 then -- Switch to File
                pinfo.cols["info"]:append(" Switch to File")
            elseif arg1 == 0x08 then -- End File
                pinfo.cols["info"]:append(" End File")
            elseif arg1 == 0x09 then -- Write to Hardware
                pinfo.cols["info"]:append(" To Hardware")
            elseif arg1 == 0x0c then -- Switch Hardware Mode
                pinfo.cols["info"]:append(string.format(" Switch to Mode %d", arg2))
            elseif arg1 == 0x0d then -- Sync
                pinfo.cols["info"]:append(" Sync")
            end
        elseif subcommand == 0x22 then -- Mouse Colour Change
    
            -- If Corsair hadn't reused this for mousepads,
            -- it might be possible to actually break it down into
            -- viewable sections. Such is the way of things.

            pinfo.cols["info"]:append(" Mouse Colour Change")

        elseif subcommand == 0x25 then -- Zoned Colour Change

            pinfo.cols["info"]:append(" Zoned Colour Change")

        elseif subcommand == 0x27 then -- 9-bit Colour Change

            pinfo.cols["info"]:append(" 9-bit Colour Change")

        elseif subcommand == 0x28 then -- 24-bit Colour Change
            
            local colour = buffer(offset, 1)
            t_cue:add(f.colour_type, colour)
            pinfo.cols["info"]:append(" 24-bit Colour Change " .. colour_types[colour:uint()])
       
        elseif subcommand == 0x40 then -- Key Input Mode
            
            pinfo.cols["info"]:append(" Key Input Mode")

        elseif subcommand == 0x48 then -- Init Sync?

            pinfo.cols["info"]:append(" Init Sync")

        elseif subcommand == 0xae then -- Mysterious 0xAE packet

            pinfo.cols["info"]:append(" Mysterious 0xAE")

            offset = offset + 2 -- Position at start of payload

            local vendor = buffer(offset, 2)
            local product = buffer(offset + 2, 2)
            local fwver = buffer(offset + 4, 2)

            t_cue:add_le(f.ident_vendor, vendor)
            t_cue:add_le(f.ident_product, product)
            t_cue:add_le(f.ident_fwver, fwver)

        elseif subcommand == 0xff then -- Read Multiple (synonym)
            local seqnum = buffer(offset, 1)
            local size = buffer(offset + 1, 1)
            local payload = buffer(offset + 2, size:uint())

            t_cue:add_le(f.payload_seqnum, seqnum)
            t_cue:add_le(f.payload_size, size)
            t_cue:add_le(f.payload_payload, payload)

            pinfo.cols["info"]:append(string.format(" Multiple Part %d: %d bytes", seqnum:uint(), size:uint()))

        else
            pinfo.cols["info"]:append(" Unknown " .. tostring(subcommand))
        end
    
    elseif command == 0x7f or command == 0xff then

        if command == 0x7f then
            pinfo.cols["info"] = "Write"
        else
            pinfo.cols["info"] = "Read"
        end

        local seqnum = subcommand
        local size = buffer(offset, 1)
        local payload = buffer(offset + 2, size:uint())

        t_cue:add_le(f.payload_seqnum, seqnum)
        t_cue:add_le(f.payload_size, size)
        t_cue:add_le(f.payload_payload, payload)

        pinfo.cols["info"]:append(string.format(" Multiple Part %d: %d bytes", seqnum:uint(), size:uint()))

    else
        pinfo.cols["info"] = "Unknown " .. tostring(command)
    end
end

usb_table = DissectorTable.get("usb.interrupt")
usb_table:add(0x03, cue_proto)
usb_table:add(0xffff, cue_proto)
