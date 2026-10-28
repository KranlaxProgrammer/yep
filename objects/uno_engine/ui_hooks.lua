if not SMODS.uno_ui_hooks then
    local orig_buttons = G.UIDEF.play_and_discard_buttons
    G.UIDEF.play_and_discard_buttons = function()
        local t = orig_buttons()
        if t and t.nodes and t.nodes[1] and t.nodes[1].nodes then
            local draw_btn = UIBox_button({
                label = {"Robar"}, button = "uno_draw_action", colour = G.C.BLUE, minw = 2.5,
            })
            table.insert(t.nodes[1].nodes, 1, draw_btn)
        end
        return t
    end

    G.FUNCS.uno_draw_action = function(e)
        if G.deck and #G.deck.cards > 0 then
            G.hand.config.card_limit = G.hand.config.card_limit + 1
            draw_card(G.deck, G.hand, 100, 'up', true)
        else
            card_eval_status_text(G.hand, 'extra', nil, nil, nil, {message = "Paso", colour = G.C.GREY})
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.5,
                func = function() G.FUNCS.uno_cpu_turn(); return true end
            }))
        end
    end

    G.FUNCS.uno_show_color_selector = function(card)
        local colors = {
            {suit = 'Hearts', name = 'Rojo', color = G.C.RED},
            {suit = 'Clubs', name = 'Verde', color = G.C.GREEN},
            {suit = 'Diamonds', name = 'Amar.', color = G.C.GOLD},
            {suit = 'Spades', name = 'Azul', color = G.C.BLUE}
        }
        local btn_nodes = {}
        for _, c in ipairs(colors) do
            if c.suit ~= G.GAME.uno_current_suit then
                table.insert(btn_nodes, UIBox_button({
                    label = {c.name}, button = 'uno_select_color', colour = c.color, minw = 2,
                    config = {chosen_suit = c.suit, card = card}
                }))
            end
        end
        G.uno_color_ui = UIBox{
            definition = {n=G.UIT.ROOT, config={align="cm", colour=G.C.BLACK, r=0.1, padding=0.2}, nodes=btn_nodes},
            config = {align="cm", offset = {x=0,y=0}, major = G.ROOM_ATTACH}
        }
    end

    G.FUNCS.uno_select_color = function(e)
        G.GAME.uno_current_suit = e.config.chosen_suit
        G.uno_color_ui:remove()
        G.uno_color_ui = nil
        G.GAME.uno_wild_resolved = true 
        G.FUNCS.play_cards_from_highlighted(nil) 
    end

    local orig_shop_reroll = G.UIDEF.shop_reroll
    G.UIDEF.shop_reroll = function()
        if not G.GAME.uno_rerolls_allowed then
            return {n=G.UIT.ROOT, config={align="cm", colour=G.C.CLEAR}, nodes={}}
        end
        return orig_shop_reroll()
    end

    SMODS.uno_ui_hooks = true
end