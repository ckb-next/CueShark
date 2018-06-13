cue_proto = Proto("cue", "Corsair Utility Engine protocol")

local commands = {
    [0x01] = "HID Event",
    [0x02] = "Media Key Event",
    [0x03] = "Corsair HID Event",
    [0x07] = "Set",
    [0x0e] = "Get",
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
    [0x0e] = "Firmware Update Synchronisation",
    [0x13] = "Mouse Specific",
    [0x14] = "Static Keyboard Profile",
    [0x15] = "Mouse Profile GUID",
    [0x16] = "Mouse Profile Name",
    [0x17] = "Dynamic Keyboard Profile",
    [0x22] = "Mouse Colour Change",
    [0x25] = "Zoned Colour Change",
    [0x27] = "9-bit Colour Change",
    [0x28] = "24-bit Colour Change",
    [0x40] = "Key Input Mode",
    [0x83] = "Wireless Pairing",
    [0xa6] = "Wireless Settings",
    [0xaa] = "Wireless Colour Change",
    [0xac] = "Wireless LED Full Brightness",
    [0xad] = "Wireless Opacity",
    [0xae] = "Wireless Identification",
    [0xff] = "Get Multiple"
}

local reset_types = {
    [0x00] = "Medium Reset",
    [0x01] = "Fast Reset",
    [0x03] = "New Reset", -- Needs to be investigated
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
    [0x1b49] = "K70 RGB MK.2",
    [0x1b11] = "K95 RGB",
    [0x1b08] = "K95",
    [0x1b2d] = "K95 PLATINUM RGB",
    [0x1b20] = "STRAFE RGB",
    [0x1b48] = "STRAFE RGB MK.2",
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
    [0x1b64] = "DARK CORE RGB Dongle",
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
    [0x03] = "JIS",
    [0x04] = "Dubeolsik"
}

local hwprofile_commands = {
    [0x05] = "New File",
    [0x07] = "Switch to File",
    [0x08] = "End File",
    [0x09] = "Write Segment",
    [0x0c] = "Switch Hardware Mode",
    [0x0d] = "Sync"
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
f.profile_guid = ProtoField.guid("cue.profile.guid", "Profile GUID")
f.profile_name = ProtoField.string("cue.profile.name", "Profile Name")

f.profile_command = ProtoField.uint8("cue.profile.command", "Profile Command", base.DEC, hwprofile_commands)
f.profile_filename = ProtoField.stringz("cue.profile.filename", "Filename")
f.profile_mode = ProtoField.uint8("cue.profile.modenum", "Profile Mode Number", base.DEC)

-- Payload fields
f.payload_payload = ProtoField.bytes("cue.payload.payload", "Payload")
f.payload_size = ProtoField.uint8("cue.payload.size", "Payload Size", base.DEC)
f.payload_seqnum = ProtoField.uint8("cue.payload.seqnum", "Payload Sequence Number", base.DEC)

-- Mouse specific
f.mouse_dpi_independent = ProtoField.bool("cue.mouse.dpi.independent", "Mouse Independent X/Y")
f.mouse_dpi_x = ProtoField.uint16("cue.mouse.dpi.x", "Mouse X DPI", base.DEC)
f.mouse_dpi_y = ProtoField.uint16("cue.mouse.dpi.y", "Mouse Y DPI", base.DEC)
f.mouse_dpi_red = ProtoField.uint8("cue.mouse.dpi.red", "Mouse DPI Indicator Red", base.DEC)
f.mouse_dpi_green = ProtoField.uint8("cue.mouse.dpi.green", "Mouse DPI Indicator Green", base.DEC)
f.mouse_dpi_blue = ProtoField.uint8("cue.mouse.dpi.blue", "Mouse DPI Indicator Blue", base.DEC)

f.mouse_snap = ProtoField.bool("cue.mouse.snap", "Angle Snap Enabled")

f.mouse_pollrate = ProtoField.uint8("cue.mouse.pollrate", "Mouse Poll Rate", base.DEC)

-- Wireless settings
f.wireless_powersave = ProtoField.uint8("cue.wireless.powersave", "Wireless Power Saving", base.DEC)
f.wireless_sleeptime = ProtoField.uint8("cue.wireless.sleeptime", "Time before sleeping (minutes)")

function cue_proto.dissector(buffer, pinfo, tree)
    -- Corsair packets are 64 bytes long.
    if buffer:len() ~= 64 then
        return
    end

    local command = buffer(offset, 1)
    -- Exclude unknown packet headers
    if command:uint() ~= 0x07 and command:uint() ~= 0x0e and
        command:uint() ~= 0x7f and command:uint() ~= 0xff then
        return
    end

    pinfo.cols["protocol"] = "CUE"

    local t_cue = tree:add(cue_proto, buffer())
    local offset = 0

    t_cue:add(f.cmd, command)
    command = command:uint()
    offset = offset + 1

    local subcommand = buffer(offset, 1)
    offset = offset + 1

    if command == 0x07 or command == 0x0e then -- Read/Write
        if command == 0x07 then
            pinfo.cols["info"] = "Set"
        else
            pinfo.cols["info"] = "Get"
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
            t_cue:add(f.ident_bldver, bldver)
            t_cue:add_le(f.ident_vendor, vendor)
            t_cue:add_le(f.ident_product, product)
            t_cue:add_le(f.ident_pollrate, pollrate)
            t_cue:add_le(f.ident_devtype, devtype)

            -- Note for the future: ~= is inequality, not !=
            if vendor:le_uint() ~= 0 and product:le_uint() ~= 0 then
                pinfo.cols["info"]:append(": " .. vendor_ids[vendor:le_uint()] .. " " .. product_ids[product:le_uint()])
            end

            -- Keyboard layout
            -- The Dark Core dongle describes itself as a keyboard,
            -- making the script choke, so exclude it.
            if devtype:uint() == 0xc0 and product:le_uint() ~= 0x1b64 then
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
            pinfo.cols["info"]:append(" " .. reset_types[reset_type:uint()])

        elseif subcommand == 0x04 then -- Special Function
            local control_type = buffer(offset, 1)
            t_cue:add(f.special_mode, control_type)

            if control_type:uint() > 2 then
                pinfo.cols["info"]:append(" Special Function Mode to Unknown")
                return
            end
            pinfo.cols["info"]:append(" Special Function Mode to " .. control_types[control_type:uint()])

        elseif subcommand == 0x05 then -- Lighting

            if command == 0x0e then
                pinfo.cols["info"]:append(" Init Sync")
                return
            end

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
            end

        elseif subcommand == 0x0a then -- Change Poll Rate

            local pollrate = buffer(offset + 2, 1)

            pinfo.cols["info"]:append(" Poll Rate")

            t_cue:add(f.mouse_pollrate, pollrate)

        elseif subcommand == 0x0c then -- Start Firmware Update

            pinfo.cols["info"]:append(" Start Firmware Update")

            -- TODO: expand this

        elseif subcommand == 0x0d then -- Firmware Update Data Position

            local position = buffer(offset + 4, 1)

            pinfo.cols["info"]:append(" Firmware Update Data Position")

            t_cue:add(f.fwupdate_position, position)

            -- TODO: expand this

        elseif subcommand == 0x0e then -- Firmware Synchronisation

            pinfo.cols["info"]:append(" Firmware Synchronisation")

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
            elseif arg1 == 0x04 then -- Angle Snap
                pinfo.cols["info"]:append(" Angle Snap")

                local snap = buffer(offset + 2, 1)

                t_cue:add(f.mouse_snap, snap)
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
                local indepxy = buffer(offset + 2, 1)
                local xdpi = buffer(offset + 3, 2)
                local ydpi = buffer(offset + 5, 2)
                local red = buffer(offset + 7, 1)
                local green = buffer(offset + 8, 1)
                local blue = buffer(offset + 9, 1)

                pinfo.cols["info"]:append(string.format(" DPI Profile %d", zone))
                t_cue:add(f.mouse_dpi_independent, indepxy)
                t_cue:add_le(f.mouse_dpi_x, xdpi)
                t_cue:add_le(f.mouse_dpi_y, ydpi)
                t_cue:add(f.mouse_dpi_red, red)
                t_cue:add(f.mouse_dpi_green, green)
                t_cue:add(f.mouse_dpi_blue, blue)
            else
                pinfo.cols["info"]:append(string.format(" Mouse Unknown %d %d", arg1, arg2))
            end

        elseif subcommand == 0x14 then -- Keyboard Profile

            local proftype = buffer(offset, 1)
            local mode = buffer(offset + 3, 1)
            local colour = buffer(offset + 4, 1)

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
            local guid = buffer(offset + 2, 16)

            if mode:uint() == 0 then
                pinfo.cols["info"]:append(" SW Profile GUID")
            else
                pinfo.cols["info"]:append(string.format(" HW Profile %d GUID", mode:uint()))
            end

            t_cue:add(f.profile_guid, guid)

        elseif subcommand == 0x16 then -- Profile Name

            local mode = buffer(offset + 1, 1)
            local name = buffer(offset + 2, 32)

            if mode:uint() == 0 then
                pinfo.cols["info"]:append(" SW Profile Name")
            else
                pinfo.cols["info"]:append(string.format(" HW Profile %d Name", mode:uint()))
            end

            -- Thanks to @Lekensteyn on GitHub for suggesting this to print UTF16LE.
            t_cue:add_packet_field(f.profile_name, name, ENC_LITTLE_ENDIAN+ENC_UTF_16)

        elseif subcommand == 0x17 then -- Dynamic Keyboard Animation

            pinfo.cols["info"]:append(" Animation")

            local arg1 = buffer(offset, 1)
            local arg2 = buffer(offset + 1, 1):uint()

            t_cue:add(f.profile_command, arg1)

            arg1 = arg1:uint()

            -- TODO: Add these to the Wireshark tree
            if arg1 == 0x05 then -- Write File
                pinfo.cols["info"]:append(" Write File: ")

                local filename = buffer(offset + 2, 11)
                t_cue:add(f.profile_name, filename)

                pinfo.cols["info"]:append(filename:string())
            elseif arg1 == 0x07 then -- Read File
                pinfo.cols["info"]:append(" Read File: ")

                local filename = buffer(offset + 2, 11)
                t_cue:add(f.profile_name, filename)

                pinfo.cols["info"]:append(filename:string())
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

        elseif subcommand == 0x83 then -- Wireless Pairing

            pinfo.cols["info"]:append(" Wireless Pairing")

            local status = buffer(offset + 2, 1):uint()

            if status == 0x01 then
                pinfo.cols["info"]:append(" Stop")
            elseif status == 0x02 then
                pinfo.cols["info"]:append(" Start")
            end

        elseif subcommand == 0xa6 then -- Wireless Settings

            pinfo.cols["info"]:append(" Wireless Settings")

            local powersave = buffer(offset    , 1)
            local sleeptime = buffer(offset + 2, 1)

            t_cue:add(f.wireless_powersave, powersave)
            t_cue:add(f.wireless_sleeptime, sleeptime)

        elseif subcommand == 0xaa then -- Wireless Colour Change

            pinfo.cols["info"]:append(" Wireless Colour Change")

            offset = offset + 2 -- Position at start of payload

            -- Mostly as a reference to myself
            local anims = {
                [0x00] = "Colour Shift",
                [0x01] = "Colour Pulse",
                [0x03] = "Rainbow",
                [0x07] = "Static Colour",
                [0xff] = "No Animation"
            }

            local lights = buffer(offset, 1)
            local anim = buffer(offset + 1, 1)
            local opacity = buffer(offset + 4, 1)

        elseif subcommand == 0xac then -- Wireless LED Full Brightness

            local state = buffer(offset + 2, 1)
            pinfo.cols["info"]:append(" Wireless LED Full Brightness")

        elseif subcommand == 0xad then -- Wireless Opacity

            local opacity = buffer(offset + 2, 1)
            pinfo.cols["info"]:append(" Wireless Opacity " .. tostring(opacity:uint()) .. "%")

        elseif subcommand == 0xae then -- Wireless Identification?

            pinfo.cols["info"]:append(" Wireless Identification")

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
