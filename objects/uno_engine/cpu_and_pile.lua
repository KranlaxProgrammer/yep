if not SMODS.uno_cpu_hook then
    local orig_setup = G.FUNCS.setup_run
    G.FUNCS.setup_run = function()
        orig_setup()
        G.cpu_hand = CardArea(
            G.consumeables.T.x, G.consumeables.T.y + G.consumeables.T.h + 0.5,
            G.consumeables.T.w, 0.6, 
            {card_limit = 100, type = 'cpu_hand', highlight_limit = 0}
        )
        G.cpu_hand.config.card_scale = 0.4

        G.uno_pile = CardArea(
            G.play.T.x, G.play.T.y - 1.5,
            G.play.T.w, G.play.T.h, 
            {card_limit = 100, type = 'uno_pile', highlight_limit = 0}
        )
    end

    G.FUNCS.uno_cpu_turn = function()
        if G.GAME.uno_cpu_draw_queue and G.GAME.uno_cpu_draw_queue > 0 then
            for i = 1, G.GAME.uno_cpu_draw_queue do
                if #G.deck.cards > 0 then draw_card(G.deck, G.cpu_hand, 100, 'down', true) end
            end
            G.GAME.uno_cpu_draw_queue = 0
            return 
        end

        local function cpu_think()
            local played_card = nil
            for _, c in ipairs(G.cpu_hand.cards) do
                local c_suit = c.base.suit
                local c_rank = c.base.value
                local c_key = c.config.center.key
                
                if c_key == 'm_yep_reverse' then c_rank = 'R' end
                if c_key == 'm_yep_skip' then c_rank = 'S' end
                if c_key == 'm_yep_plus_2' then c_rank = 'P2' end
                local is_wild = (c_key == 'm_yep_uno_wild' or c_key == 'm_yep_wild_plus_4')

                if not G.GAME.uno_current_suit or c_suit == G.GAME.uno_current_suit or c_rank == G.GAME.uno_current_rank or is_wild then
                    played_card = c
                    break
                end
            end

            if played_card then
                played_card:flip()
                draw_card(G.cpu_hand, G.uno_pile, 100, 'up', true)
                
                local c_key = played_card.config.center.key
                local c_rank = played_card.base.value
                if c_key == 'm_yep_reverse' then c_rank = 'R' end
                if c_key == 'm_yep_skip' then c_rank = 'S' end
                if c_key == 'm_yep_plus_2' then c_rank = 'P2' end
                
                if c_key == 'm_yep_uno_wild' or c_key == 'm_yep_wild_plus_4' then
                    local suits = {'Hearts', 'Clubs', 'Diamonds', 'Spades'}
                    G.GAME.uno_current_suit = pseudorandom_element(suits, pseudoseed('cpu_wild'))
                else
                    G.GAME.uno_current_suit = played_card.base.suit
                end
                G.GAME.uno_current_rank = c_rank

                if #G.cpu_hand.cards == 0 then
                    card_eval_status_text(G.cpu_hand, 'extra', nil, nil, nil, {message = "CPU GANA", colour = G.C.RED})
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after', delay = 1.0,
                        func = function()
                            G.STATE = G.STATES.GAME_OVER
                            G.STATE_COMPLETE = false
                            return true
                        end
                    }))
                    return
                end

                if c_rank == 'S' or c_rank == 'R' then
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1.0, func = function() cpu_think(); return true end}))
                end
            else
                if #G.deck.cards > 0 then
                    draw_card(G.deck, G.cpu_hand, 100, 'down', true)
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function() cpu_think(); return true end}))
                else
                    card_eval_status_text(G.cpu_hand, 'extra', nil, nil, nil, {message = "CPU Pasa", colour = G.C.GREY})
                end
            end
        end
        cpu_think() 
    end

    local orig_discard = G.FUNCS.draw_from_play_to_discard
    G.FUNCS.draw_from_play_to_discard = function(e)
        if G.play and #G.play.cards > 0 then
            for i = #G.play.cards, 1, -1 do draw_card(G.play, G.uno_pile, 100, 'up', true) end
        end
        if #G.uno_pile.cards > 1 then draw_card(G.uno_pile, G.discard, 100, 'up', true, G.uno_pile.cards[1]) end
        orig_discard(e)
    end

    SMODS.uno_cpu_hook = true
end