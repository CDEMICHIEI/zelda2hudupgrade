-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Zelda 2 Help Script
-- Christopher DeMichiei
-- -- -- --
-- There's a lot of stuff I wish I could see while playing Zelda 2, so I made this.
-- Includes:
-- Displays HP and MP in numeric form
-- Displays enemy HP
-- Number keys and lives are displayed w/o pausing
-- Displays currently selected spell and MP cost
-- Displays damage taken.
-- Shows enemy drop counters
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- occassionally something causes the coords of screen drawing to be wrong.
-- might be emulator version?
topScreenOffset = 8
gui.transparency(0.0)
-- color definition
clear = "\127\0\0\0"
white = "\0\255\255\255"
blue = "\0\0\40\255"
red = "\0\255\40\0"

--
--

--------------------------------------------------------------------------------
-- ** Stole the following font code from Metroid LUA Script by Neill Corlett **
--
-- Create gd image out of an 8x8, 4-color tile in ROM
--
local function gdTile(ofs,c0,c1,c2,c3,hflip,double)
    local gd = 		"\255\254\0\008\0\008\001\255\255\255\255"
    if double then gd = 	"\255\254\0\016\0\016\001\255\255\255\255" end
    for y=0,7 do
        local v0 = rom.readbyte(ofs + y    )
        local v1 = rom.readbyte(ofs + y + 8)
        local line = ""
        if hflip then
            for x=0,7 do
                local px
                if AND(v1,1) ~= 0 then
                    if AND(v0,1) ~= 0 then
                        v0 = v0 - 128
                        px = c3
                    else
                        px = c2
                    end
                else
                    if AND(v0,1) ~= 0 then
                        px = c1
                    else
                        px = c0
                    end
                end
                line = line .. px
                if double then line = line .. px end
                v1 = math.floor(v1/2)
                v0 = math.floor(v0/2)
            end
        else
            for x=0,7 do
                if v1 >= 128 then
                    v1 = v1 - 128
                    if v0 >= 128 then
                        v0 = v0 - 128
                        px = c3
                    else
                        px = c2
                    end
                else
                    if v0 >= 128 then
                        v0 = v0 - 128
                        px = c1
                    else
                        px = c0
                    end
                end
                line = line .. px
                if double then line = line .. px end
                v1 = v1 * 2
                v0 = v0 * 2
            end
        end
        gd = gd .. line
        if double then gd = gd .. line end
    end
    return gd
end

--
-- Same thing, but pre-defined colors (a/R/G/B)
--
local function gdMonoTile(ofs)
    return gdTile(ofs, clear, white, blue, red)
end

local function gdMonoTileRed(ofs)
    return gdTile(ofs, clear, white, red, blue)
end


--
-- Use a string manually
--
local function gdMonoTileStr(str)
    local gd = "\255\254\0\008\0\008\001\255\255\255\255"
    for y=0,7 do
        for x=0,7 do
            if string.byte(str,1+8*y+x) > 32 then
                gd = gd ..  white
            else
                gd = gd ..  clear
            end
        end
    end
    return gd
end

--
-- Just create a solid 8x8 tile
--
local function gdSolidTile(color)
    return "\255\254\0\008\0\008\001\255\255\255\255" .. string.rep(color,64)
end

--
-- Create font
--
local Z2Font = {
    --
    -- Characters that exist in ROM
    --
    [string.byte("-")] = gdMonoTile(0x021F70), -- 
	[string.byte(".")] = gdMonoTile(0x021D0), --
    [string.byte("!")] = gdMonoTile(0x021FB0), -- JAR
    [string.byte(";")] = gdMonoTileRed(0x021FB0), -- JAR (Red)
    [string.byte("/")] = gdMonoTile(0x021CF0), -- 
    [string.byte("#")] = gdMonoTile(0x021CA0), -- Sword
    [string.byte("^")] = gdMonoTile(0x021F90), -- Heart
    [string.byte(">")] = gdMonoTile(0x021FC0), -- Arrow
    [string.byte("*")] = gdMonoTile(0x021FD0), -- X (multiplier)
    [string.byte("[")] = gdMonoTile(0x021FE0), -- white square
    [string.byte("]")] = gdMonoTile(0x021FF0), -- blue square
    [string.byte("=")] = gdMonoTile(0x021FF0), -- red square
    [string.byte("+")] = gdMonoTile(0x021CB0), -- corner
    [string.byte("_")] = gdMonoTile(0x021CC0), -- hori bar
    [string.byte("|")] = gdMonoTile(0x021CD0), -- verti bar
    [string.byte("$")] = gdMonoTile(0x021BA0), -- Key
    [string.byte("@")] = gdMonoTile(0x021970), -- Life Head
    --
    -- Characters we have to supply
  [string.byte(":")] = gdMonoTileStr(
        "        " ..
        "   xx   " ..
        "   xx   " ..
        "        " ..
        "   xx   " ..
        "   xx   " ..
        "        " ..
        "        "
    ),    --

}
for i=48, 57 do Z2Font[i] = gdMonoTile(0x021D10 + 0x10 * (i-48)) end -- 0-9
for i=65, 90 do Z2Font[i] = gdMonoTile(0x21DB0 + 0x10 * (i-65)) end -- A-Z
for i=97,122 do Z2Font[i] = gdMonoTile(0x021DB0+ 0x10 * (i-97)) end -- a-z (same as upper)

--
-- Draw text on the screen in the Z2 font
--
local function drawZ2Font(x, y, str)
    local ox = x
    for i=1,#str do
        local b = string.byte(str,i)
        if b == 10 then
            y = y + 8
            x = ox
        else
            local tile = Z2Font[b]
            if tile then gui.gdoverlay(x, y + topScreenOffset, tile) end
            x = x + 8
        end
    end
end

local function drawZ2FontCenter(y, str)
    drawZ2Font(128 - 4 * #str, y, str)
end

-- ** End Neill Corlett's Metroid Code **
--------------------------------------
readByte = memory.readbyte
prevLife = math.ceil(readbyte(0x0774)/2)
DamageTimer = 0

spells = {"Shield","Jump","Life","Fairy","Fire","Reflect","Spell","Thunder"}
spellCost = {}

-- Start emu loop

while true do

-- Determine spell costs for each spell 
-- This can change with Magic Level, so read from a ROM table
for i=0,7 do
 spellCost[i+1] = {}
	 for j=0,7 do
		spellCost[i+1][j+1] = math.ceil(rom.readbyte(0x000D8B + i*8 + j )/2)
	 end
end

local rawLife = readbyte(0x0774)
local nowLife = math.ceil(rawLife/2)
local rawMagic = readbyte(0x0773)
local Magic = math.ceil(rawMagic/2)
local Keys = readbyte(0x0793)
local Lives = readbyte(0x0700)
local LinkX = readByte(0x0015)
local LinkY = readByte(0x0029)

local AttackLevel = readByte(0x0777)
local MagicLevel = readByte(0x0778)
local LifeLevel = readByte(0x0779)

-- Show Keys and Lives count
drawZ2Font(176,08,"$*"..Keys) -- "$" is Keys Symbol
drawZ2Font(220,216,"@*"..Lives) -- "@" is Lives Symbol

-- List enemies' HP
-- If an enemy's HP goes below zero, it will underflow to 255 but not be removed from list
-- So don't show values for HP > 200. This currently hides HP from Bubbles until they are 
-- damaged a bit.
for i=0,5 do
	local enHP = readByte(0x00C7 - i)
	if enHP ~= 0 and enHP <200 then
		drawZ2Font(0,215-(8*i), i..':'..enHP)
	end
end

-- every sixth enemy drops item
local dropCount = readByte(0x05DF)
local dropCountLarge = readByte(0x05E0)
for i=0,5 do
	if i < dropCount then
        dropColor = 'green'
        dropChar = "+"
	else
        dropColor = 'red'
        dropChar = "-"
	end

	if i == 5 then
        dropColor = 'orange'
        dropChar = "!"
	end

    drawZ2Font(176 + i * 8, 24, dropChar)

	if i < dropCountLarge then
        dropColor = 'green'
        dropChar = "+"
	else
        dropColor = 'red'
        dropChar = "-"
	end
	if i == 5 then
        dropColor = 'orange'
        dropChar = ";"
	end

    drawZ2Font(176 + i * 8, 32, dropChar)
end


-- show equipped spell and spell cost
local equippedSpell = readByte(0x0749)
local isSpellReady = readByte(0x0F4A)
if isSpellReady == 0 then
	magicCost = spellCost[equippedSpell+1][MagicLevel]
	if magicCost == nil then magicCost = 0 end
	drawZ2Font(166,208,spells[equippedSpell+1].." "..magicCost)
	if magicCost <= Magic then
		local x1 = 40 + Magic/2
		gui.drawbox(x1, 16 + topScreenOffset, x1 - magicCost/2, 22 + topScreenOffset, 0xFFff0000)
	end

end


-- Show Life numeric value
drawZ2Font(104, 23, "^"..nowLife)
-- Show Magic numeric value
drawZ2Font(32, 23, "!"..Magic)


-- Displays damage taken over the last 60 frames
if  nowLife ~= prevLife then
	if DamageTimer <= 0 then
		LifeAtHit = prevLife
	end
	DamageTimer = 60
	end
prevLife = nowLife

DamageTimer = DamageTimer - 1
if DamageTimer > 0 then
	Damage = nowLife - LifeAtHit
    -- yUp moves the value upwards over time, like in-game exp
	local yUp = DamageTimer / 12
	drawZ2Font(LinkX, LinkY - 12 + yUp, ""..Damage)
end

emu.frameadvance();
end
