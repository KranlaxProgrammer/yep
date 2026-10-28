SMODS.Back {
    key = 'uno_deck',
    name = "Baraja UNO",
    atlas = 'UnoJokers', 
    pos = {x = 0, y = 0},
    config = { hands = 7, discards = 0, joker_slot = 4, consumable_slot = 1, hand_size = 7 },
    
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = #G.playing_cards, 1, -1 do
                    local c = G.playing_cards[i]
                    if c and c.playing_card then c:remove() end
                end
                
                local suits = {'Hearts', 'Clubs', 'Diamonds', 'Spades'}
                for _, suit in ipairs(suits) do
                    create_playing_card({front = G.P_CARDS[suit..'_Queen'], center = G.P_CENTERS.c_base}, G.deck, nil, nil, {G.C.SECONDARY_SET.Enhanced})
                    
                    local ranks = {'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10'}
                    for _, rank in ipairs(ranks) do
                        for i = 1, 2 do
                            create_playing_card({front = G.P_CARDS[suit..'_'..rank], center = G.P_CENTERS.c_base}, G.deck, nil, nil, {G.C.SECONDARY_SET.Enhanced})
                        end
                    end
                    
                    local actions = {'m_yep_reverse', 'm_yep_skip', 'm_yep_plus_2'}
                    for _, action in ipairs(actions) do
                        for i = 1, 2 do
                            create_playing_card({front = G.P_CARDS[suit..'_Jack'], center = G.P_CENTERS[action]}, G.deck, nil, nil, {G.C.SECONDARY_SET.Enhanced})
                        end
                    end
                end
                
                for i = 1, 4 do
                    create_playing_card({front = G.P_CARDS['Spades_Jack'], center = G.P_CENTERS.m_yep_uno_wild}, G.deck, nil, nil, {G.C.SECONDARY_SET.Enhanced})
                    create_playing_card({front = G.P_CARDS['Spades_Jack'], center = G.P_CENTERS.m_yep_wild_plus_4}, G.deck, nil, nil, {G.C.SECONDARY_SET.Enhanced})
                end
                
                G.GAME.modifiers.no_skips = true 
                G.GAME.modifiers.no_interest = true 
                G.GAME.modifiers.money_per_hand = 0 
                G.GAME.modifiers.money_per_discard = 0 
                G.GAME.win_ante = 3
                
                if G.deck and G.deck.cards then G.deck:hard_set_T() end
                return true
            end
        }))
    end
}