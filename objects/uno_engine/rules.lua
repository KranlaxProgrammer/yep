if not SMODS.uno_rules_hook then
    local orig_start_run = Game.start_run
    function Game:start_run(args)
        orig_start_run(self, args)
        G.GAME.uno_current_suit = nil
        G.GAME.uno_current_rank = nil
        G.GAME.uno_rerolls_allowed = false
    end

    local orig_set_blind = Blind.set_blind
    function Blind:set_blind(blind)
        orig_set_blind(self, blind)
        G.GAME.uno_current_suit = nil
        G.GAME.uno_current_rank = nil
        self.chips = 999999999 
        self.dollars = 0
    end

    local function get_uno_rank(card)
        local c_key = card.config.center.key
        if c_key == 'm_yep_reverse' then return 'R' end
        if c_key == 'm_yep_skip' then return 'S' end
        if c_key == 'm_yep_plus_2' then return 'P2' end
        if c_key == 'm_yep_uno_wild' then return 'W' end
        if c_key == 'm_yep_wild_plus_4' then return 'P4W' end
        return card.base.value
    end

    local orig_play = G.FUNCS.play_cards_from_highlighted
    G.FUNCS.play_cards_from_highlighted = function(e)
        if not G.hand.highlighted or #G.hand.highlighted == 0 then return end
        local card = G.hand.highlighted[1]
        if #G.hand.highlighted ~= 1 then play_sound('cancel'); return end

        local c_suit = card.base.suit
        local c_rank = get_uno_rank(card)
        local is_wild = (c_rank == 'W' or c_rank == 'P4W')

        if is_wild and not G.GAME.uno_wild_resolved then
            G.FUNCS.uno_show_color_selector(card)
            return
        end

        if not G.GAME.uno_wild_resolved and G.GAME.uno_current_suit then
            if not (c_suit == G.GAME.uno_current_suit or c_rank == G.GAME.uno_current_rank) then
                card:juice_up(0.5, 0.5); play_sound('cancel')
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Ilegal", colour = G.C.RED})
                return
            end
        end

        if not is_wild then G.GAME.uno_current_suit = c_suit end
        G.GAME.uno_current_rank = c_rank
        G.GAME.uno_wild_resolved = false
        G.hand.config.card_limit = math.max(1, G.hand.config.card_limit - 1)

        if c_rank == 'P2' then G.GAME.uno_cpu_draw_queue = 2 end
        if c_rank == 'P4W' then G.GAME.uno_cpu_draw_queue = 4 end
        
        orig_play(e)

        if c_rank ~= 'S' and c_rank ~= 'R' then
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 1.5,
                func = function() G.FUNCS.uno_cpu_turn(); return true end
            }))
        else
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Turno Extra", colour = G.C.GREEN})
        end
    end

    local orig_eval = G.FUNCS.evaluate_play
    G.FUNCS.evaluate_play = function(e)
        if #G.hand.cards == 0 then G.GAME.uno_player_won = true end
        orig_eval(e)
        if G.GAME.uno_player_won then
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 1.0,
                func = function()
                    ease_chips(G.GAME.blind.chips + 100)
                    return true
                end
            }))
            G.GAME.uno_player_won = false
        end
    end

    SMODS.uno_rules_hook = true
end