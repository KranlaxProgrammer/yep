local mod_path = "" .. SMODS.current_mod.path
UNO_MOD = SMODS.current_mod
UNO_MOD.config = UNO_MOD.config or {}

local NFS = require("nativefs")
local function load_folder(path)
    local files = NFS.getDirectoryItemsInfo(mod_path .. "/" .. path)
    if files then
        for i = 1, #files do
            local file_name = files[i].name
            if string.sub(file_name, -4) == ".lua" then
                assert(SMODS.load_file(path .. file_name))()
            end
        end
    end
end

SMODS.Atlas({ key = "modicon", path = "ModIcon.png", px = 34, py = 34, atlas_table = "ASSET_ATLAS" })
SMODS.Atlas({ key = "balatro", path = "balatro.png", px = 333, py = 216, prefix_config = { key = false }, atlas_table = "ASSET_ATLAS" })
SMODS.Atlas({ key = 'UnoJokers', path = 'UnoJokers.png', px = 71, py = 95 })
SMODS.Atlas({ key = 'UnoConsumables', path = 'UnoConsumables.png', px = 71, py = 95 })
SMODS.Atlas({ key = 'UnoCards', path = 'UnoCards.png', px = 71, py = 95 })
SMODS.Atlas({ key = 'UnoSuitsUI', path = 'UnoSuitsUI.png', px = 18, py = 18 })
SMODS.Atlas({ key = 'UnoEnhancements', path = 'UnoEnhancements.png', px = 71, py = 95 })
SMODS.Atlas({ key = 'UnoVouchers', path = 'UnoVouchers.png', px = 71, py = 95 })

local function override_vanilla_cards()
    local suits_to_override = {'Hearts', 'Clubs', 'Diamonds', 'Spades'}
    for _, suit_key in ipairs(suits_to_override) do
        local suit_obj = SMODS.Suit.obj_table[suit_key]
        if suit_obj then
            suit_obj.lc_atlas = 'UnoCards'
            suit_obj.hc_atlas = 'UnoCards'
            suit_obj.lc_ui_atlas = 'UnoSuitsUI'
            suit_obj.hc_ui_atlas = 'UnoSuitsUI'
        end
    end
end
override_vanilla_cards()

-- CARGAR TODOS LOS MÓDULOS DEL MOTOR UNO
load_folder("objects/uno_engine/")
load_folder("objects/enhancements/")
load_folder("objects/decks/")
load_folder("objects/vouchers/")

-- =========================================
-- PURGA DE CONVERSIÓN TOTAL (TOTAL CONVERSION)
-- =========================================
if not SMODS.uno_total_conversion_hook then
    local orig_update = Game.update
    function Game:update(dt)
        if orig_update then orig_update(self, dt) end
        
        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Back and not G.uno_purged then
            -- 1. PURGAR BARAJAS
            local uno_decks = {}
            for _, back in ipairs(G.P_CENTER_POOLS.Back) do
                if string.find(back.key, "yep") or string.find(back.key, "uno_deck") then
                    table.insert(uno_decks, back)
                else
                    back.no_collection = true
                    back.unlocked = false
                end
            end
            if #uno_decks == 0 and G.P_CENTERS.b_red then table.insert(uno_decks, G.P_CENTERS.b_red) end
            G.P_CENTER_POOLS.Back = uno_decks 
            
            -- 2. PURGAR APUESTAS (Solo White Stake)
            if G.P_CENTER_POOLS.Stake then
                local white_stake = { G.P_CENTERS.stake_white }
                G.P_CENTER_POOLS.Stake = white_stake
            end

            -- 3. PURGAR VOUCHERS
            if G.P_CENTER_POOLS.Voucher then
                local uno_vouchers = {}
                for _, v in ipairs(G.P_CENTER_POOLS.Voucher) do
                    if string.find(v.key, "yep") or string.find(v.key, "aumento_mano") or string.find(v.key, "mas_cuerda") or string.find(v.key, "extension_estanteria") or string.find(v.key, "mas_opciones") or string.find(v.key, "intercambio") then
                        table.insert(uno_vouchers, v)
                    else
                        v.no_collection = true
                        v.unlocked = false
                    end
                end
                G.P_CENTER_POOLS.Voucher = uno_vouchers
            end
            
            G.uno_purged = true 
        end
    end
    SMODS.uno_total_conversion_hook = true
end

SMODS.current_mod.optional_features = function()
    return { cardareas = {} }
end