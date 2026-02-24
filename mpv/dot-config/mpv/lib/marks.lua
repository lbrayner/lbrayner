local concat = table.concat
local mark_dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/marks"

local M = {}

local function jump_to_mark(slot)
  mp.osd_message(concat({ "Jump to mark", slot }, " "))
end

local function set_mark(slot)
  mp.osd_message(concat({ "Mark", slot, "set" }, " "))
end

for i = 0, 9 do
  M[concat({ "jump_to_mark_", i })] = function()
    jump_to_mark(i)
  end

  M[concat({ "set_mark_", i })] = function()
    set_mark(i)
  end
end

return M
