SMODS.Voucher {
    key = 'aumento_mano', atlas = 'UnoVouchers', pos = {x = 0, y = 0}, cost = 10,
    loc_txt = { name = "Aumento de Mano", text = { "+1 tamaño de mano inicial", "{C:attention}Se puede comprar varias veces{}" } },
    redeem = function(self)
        G.hand:change_size(1)
        G.E_MANAGER:add_event(Event({func = function() G.GAME.used_vouchers[self.key] = nil; return true end}))
    end
}

SMODS.Voucher {
    key = 'mas_cuerda', atlas = 'UnoVouchers', pos = {x = 1, y = 0}, cost = 10,
    loc_txt = { name = "Más Cuerda", text = { "+1 espacio para consumibles", "{C:attention}Se puede comprar varias veces{}" } },
    redeem = function(self)
        G.E_MANAGER:add_event(Event({func = function() 
            G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
            G.GAME.used_vouchers[self.key] = nil
            return true 
        end}))
    end
}

SMODS.Voucher {
    key = 'extension_estanteria', atlas = 'UnoVouchers', pos = {x = 2, y = 0}, cost = 10,
    loc_txt = { name = "Extensión de Estantería", text = { "+1 espacio para Jokers", "{C:attention}Se puede comprar varias veces{}" } },
    redeem = function(self)
        G.E_MANAGER:add_event(Event({func = function() 
            if G.jokers then G.jokers.config.card_limit = G.jokers.config.card_limit + 1 end
            G.GAME.used_vouchers[self.key] = nil
            return true 
        end}))
    end
}

SMODS.Voucher {
    key = 'mas_opciones', atlas = 'UnoVouchers', pos = {x = 3, y = 0}, cost = 10,
    loc_txt = { name = "Más Opciones", text = { "+2 opciones en la tienda", "+1 espacio para Sobres (Booster Packs)" } },
    redeem = function(self)
        G.GAME.modifiers.shop_options = G.GAME.modifiers.shop_options + 2
        G.GAME.modifiers.booster_packs = G.GAME.modifiers.booster_packs + 1
    end
}

SMODS.Voucher {
    key = 'intercambio', atlas = 'UnoVouchers', pos = {x = 4, y = 0}, cost = 10,
    loc_txt = { name = "Intercambio", text = { "Habilita el {C:attention}Reroll{} en la tienda.", "Cuesta {C:money}$10{} y aumenta", "de {C:money}$10{} en {C:money}$10{}" } },
    redeem = function(self)
        G.GAME.uno_rerolls_allowed = true
        G.GAME.round_resets.reroll_cost = 10
        G.GAME.round_resets.reroll_cost_inc = 10
        calculate_reroll_cost(true)
    end
}