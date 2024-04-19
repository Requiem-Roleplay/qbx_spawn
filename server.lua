---@param cid string
---@return table?
lib.callback.register('qb-spawn:server:getOwnedHouses', function(_, cid)
    if cid ~= nil then
    --    local houses = MySQL.query.await('SELECT * FROM player_houses WHERE citizenid = ?', {cid})
    --    if houses[1] ~= nil then
    --        return houses
    --    end
        local houses = MySQL.query.await('SELECT * FROM properties WHERE owner_citizenid = ?', {cid})
        if houses[1] ~= nil then
            return houses
        else
            return {}
        end
    else
        return {}
    end
end)