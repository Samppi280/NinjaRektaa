TriggerEvent("es:addGroup", "mod", "user", function(group) end)

-- Modify if you want, btw the _admin_ needs to be able to target the group and it will work
local groupsRequired = {
	slay = "admin",
	noclip = "admin",
	crash = "superadmin",
	freeze = "admin",
	bring = "admin",
	["goto"] = "admin",
	slap = "superadmin",
	slay = "admin",
	kick = "admin",
	ban = "admin"
}

local banned = ""
local bannedTable = {}

function loadBans()
	banned = LoadResourceFile("es_admin2", "data/bans.txt") or ""
	if banned then
		local b = stringsplit(banned, "\n")
		for k,v in ipairs(b) do
			bannedTable[v] = true
		end
	end

	if GetConvar("es_admin2_globalbans", "0") == "1" then
		PerformHttpRequest("http://essentialmode.com/bans.txt", function(err, rText, headers)
			local b = stringsplit(rText, "\n")
			for k,v in pairs(b)do
				bannedTable[v] = true
			end
		end)
	end
end

function isBanned(id)
	return bannedTable[id]
end

function banUser(id)
	banned = banned .. id .. "\n"
	SaveResourceFile("es_admin2", "data/bans.txt", banned, -1)
	bannedTable[id] = true
end

AddEventHandler('playerConnecting', function(user, set)
	for k,v in ipairs(GetPlayerIdentifiers(source))do
		if isBanned(v) then
			set(GetConvar("es_admin_banreason", "You're banned from this server"))
			CancelEvent()
			break
		end
	end
end)

RegisterServerEvent('es_admin:all')
AddEventHandler('es_admin:all', function(type)
	local Source = source
	TriggerEvent('es:getPlayerFromId', source, function(user)
		TriggerEvent('es:canGroupTarget', user.getGroup(), "admin", function(available)
			if available and user.getGroup() == "superadmin" then
				TriggerEvent("serverlog", GetPlayerName(Source).. " käytti pika komentoa: " .. type .. " admin menusta pelaajaan " .. GetPlayerName(tonumber(id)) )
				if type == "slay_all" then TriggerClientEvent('es_admin:quick', -1, 'slay') end
				if type == "bring_all" then TriggerClientEvent('es_admin:quick', -1, 'bring', Source) end
				if type == "slap_all" then TriggerClientEvent('es_admin:quick', -1, 'slap') end
			else
				TriggerClientEvent('chatMessage', Source, "SYSTEM", {255, 0, 0}, "You do not have permission to do this")
			end
		end)
	end)
end)

RegisterServerEvent('es_admin:quick')
AddEventHandler('es_admin:quick', function(id, type)
	local Source = source
	TriggerEvent('es:getPlayerFromId', source, function(user)
		TriggerEvent('es:getPlayerFromId', id, function(target)
			TriggerEvent('es:canGroupTarget', user.getGroup(), groupsRequired[type], function(available)
				print('Available?: ' .. tostring(available))
				TriggerEvent('es:canGroupTarget', user.getGroup(), target.getGroup(), function(canTarget)
					if canTarget and available then
						TriggerEvent("serverlog", GetPlayerName(Source).. " käytti pika komentoa: " .. type .. " admin menusta pelaajaan " .. GetPlayerName(tonumber(id)) )
						if type == "slay" then TriggerClientEvent('es_admin:quick', id, type) end
						if type == "noclip" then TriggerClientEvent('es_admin:quick', id, type) end
						if type == "freeze" then TriggerClientEvent('es_admin:quick', id, type) end
						if type == "crash" then TriggerClientEvent('es_admin:quick', id, type) end
						if type == "bring" then TriggerClientEvent('es_admin:quick', id, type, Source) end
						if type == "goto" then TriggerClientEvent('es_admin:quick', Source, type, id) end
						if type == "slap" then TriggerClientEvent('es_admin:quick', id, type) end
						if type == "slay" then TriggerClientEvent('es_admin:quick', id, type) end
						if type == "kick" then DropPlayer(id, 'Kicked by es_admin GUI') end
					
						if type == "ban" then
							for k,v in ipairs(GetPlayerIdentifiers(id))do
								banUser(v)
							end
							DropPlayer(id, GetConvar("es_admin_banreason", "You were banned from this server"))
						end
					else
						if not available then
							TriggerClientEvent('chatMessage', Source, 'SYSTEM', {255, 0, 0}, "Your group can not use this command.")
						else
							TriggerClientEvent('chatMessage', Source, 'SYSTEM', {255, 0, 0}, "Permission denied.")
						end
					end
				end)
			end)
		end)
	end)
end)

AddEventHandler('es:playerLoaded', function(Source, user)
	TriggerClientEvent('es_admin:setGroup', Source, user.getGroup())
	TriggerEvent("serverlog", GetPlayerName(Source).. " tuli servulle groupilla: " .. tostring(user.getGroup()))
end)

RegisterServerEvent('es_admin:set')
AddEventHandler('es_admin:set', function(t, USER, GROUP)
	local Source = source
	TriggerEvent('es:getPlayerFromId', source, function(user)
		TriggerEvent('es:canGroupTarget', user.getGroup(), "admin", function(available)
			if available and user.getGroup() == "superadmin" then
				if t == "group" then
					if(GetPlayerName(USER) == nil)then
						TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, "Player not found")
					else
						TriggerEvent("es:getAllGroups", function(groups)
							if(groups[GROUP])then
								TriggerEvent("es:setPlayerData", USER, "group", GROUP, function(response, success)
									TriggerClientEvent('es_admin:setGroup', USER, GROUP)
									TriggerClientEvent('chatMessage', -1, "CONSOLE", {0, 0, 0}, "Group of ^2^*" .. GetPlayerName(tonumber(USER)) .. "^r^0 has been set to ^2^*" .. GROUP)
									TriggerEvent("serverlog", GetPlayerName(source).. " käytti setgroup komentoa admin menusta pelaajaan " .. GetPlayerName(tonumber(USER)) .. " uusi group: " .. GROUP)
								end)
							else
								TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, "Group not found")
							end
						end)
					end
				elseif t == "level" then
					if(GetPlayerName(USER) == nil)then
						TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, "Player not found")
					else
						GROUP = tonumber(GROUP)
						if(GROUP ~= nil and GROUP > -1)then
							TriggerEvent("es:setPlayerData", USER, "permission_level", GROUP, function(response, success)
								if(true)then
									TriggerClientEvent('chatMessage', -1, "CONSOLE", {0, 0, 0}, "Permission level of ^2" .. GetPlayerName(tonumber(USER)) .. "^0 has been set to ^2 " .. tostring(GROUP))
									TriggerEvent("serverlog", GetPlayerName(source).. " käytti perm lvl komentoa admin menusta pelaajaan " .. GetPlayerName(tonumber(USER)) .. " uusi perm lvl: " .. tostring(GROUP))
								end
							end)	
						else
							TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, "Invalid integer entered")
						end
					end
				elseif t == "money" then
					if(GetPlayerName(USER) == nil)then
						TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, "Player not found")
					else
						GROUP = tonumber(GROUP)
						if(GROUP ~= nil and GROUP > -1)then
							TriggerEvent('es:getPlayerFromId', USER, function(target)
								target.setMoney(GROUP)
								TriggerEvent("serverlog", GetPlayerName(source).. " käytti RAHA komentoa admin menusta pelaajaan " .. GetPlayerName(tonumber(USER)) .. " summa: " .. tostring(GROUP))
							end)
						else
							TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, "Invalid integer entered")
						end
					end
				elseif t == "bank" then
					if(GetPlayerName(USER) == nil)then
						TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, "Player not found")
					else
						GROUP = tonumber(GROUP)
						if(GROUP ~= nil and GROUP > -1)then
							TriggerEvent('es:getPlayerFromId', USER, function(target)
								target.setBankBalance(GROUP)
								TriggerEvent("serverlog", GetPlayerName(source).. " käytti PANKKI komentoa admin menusta pelaajaan " .. GetPlayerName(tonumber(USER)) .. " summa: " .. tostring(GROUP))
							end)
						else
							TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, "Invalid integer entered")
						end
					end
				end
			else
				TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, "superadmin required to do this")
				TriggerEvent("serverlog", GetPlayerName(source).. " Yritti käyttää superadmin juttuja admin menusta ")
			end
		end)
	end)	
end)

-- Rcon commands
AddEventHandler('rconCommand', function(commandName, args)
	if commandName == 'setadmin' then
		if #args ~= 2 then
				RconPrint("Usage: setadmin [user-id] [permission-level]\n")
				CancelEvent()
				return
		end

		if(GetPlayerName(tonumber(args[1])) == nil)then
			RconPrint("Player not ingame\n")
			CancelEvent()
			return
		end

		TriggerEvent("es:setPlayerData", tonumber(args[1]), "permission_level", tonumber(args[2]), function(response, success)
			RconPrint(response)

			if(true)then
				print(args[1] .. " " .. args[2])
				TriggerClientEvent('es:setPlayerDecorator', tonumber(args[1]), 'rank', tonumber(args[2]), true)
				TriggerClientEvent('chatMessage', -1, "CONSOLE", {0, 0, 0}, "Permission level of ^2" .. GetPlayerName(tonumber(args[1])) .. "^0 has been set to ^2 " .. args[2])
				TriggerEvent("serverlog", " Consolessa käytettiin /setadmin komentoa pelaajaan " .. GetPlayerName(tonumber(args[1])) .. " uusi perm lvl: " .. args[2])
			end
		end)

		CancelEvent()
	elseif commandName == 'setgroup' then
		if #args ~= 2 then
				RconPrint("Usage: setgroup [user-id] [group]\n")
				CancelEvent()
				return
		end

		if(GetPlayerName(tonumber(args[1])) == nil)then
			RconPrint("Player not ingame\n")
			CancelEvent()
			return
		end

		TriggerEvent("es:getAllGroups", function(groups)

			if(groups[args[2]])then
				TriggerEvent("es:setPlayerData", tonumber(args[1]), "group", args[2], function(response, success)

					if(true)then
						TriggerClientEvent('es:setPlayerDecorator', tonumber(args[1]), 'group', tonumber(args[2]), true)
						TriggerClientEvent('chatMessage', -1, "CONSOLE", {0, 0, 0}, "Group of ^2^*" .. GetPlayerName(tonumber(args[1])) .. "^r^0 has been set to ^2^*" .. args[2])
						TriggerEvent("serverlog", " Consolessa käytettiin /setgroup komentoa pelaajaan " .. GetPlayerName(tonumber(args[1])) .. " uusi group: " .. args[2])

					end
				end)
			else
				RconPrint("This group does not exist.\n")
			end
		end)

		CancelEvent()
	elseif commandName == 'giverole' then
		if #args < 2 then
				RconPrint("Usage: giverole [user-id] [role]\n")
				CancelEvent()
				return
		end

		if(GetPlayerName(tonumber(args[1])) == nil)then
			RconPrint("Player not ingame\n")
			CancelEvent()
			return
		end

			TriggerEvent("es:getPlayerFromId", tonumber(args[1]), function(user)
				table.remove(args, 1)
				user.giveRole(table.concat(args, " "))
				TriggerEvent("serverlog", " Consolessa käytettiin /giverole komentoa pelaajaan " .. GetPlayerName(tonumber(args[1])) .. " uusi rooli: " .. table.concat(args, " "))
				TriggerClientEvent("chatMessage", user.get('source'), "SYSTEM", {255, 0, 0}, "You've been given a role: ^2" .. table.concat(args, " "))
			end)

		CancelEvent()
	elseif commandName == 'removerole' then
		if #args < 2 then
				RconPrint("Usage: removerole [user-id] [role]\n")
				CancelEvent()
				return
		end

		if(GetPlayerName(tonumber(args[1])) == nil)then
			RconPrint("Player not ingame\n")
			CancelEvent()
			return
		end

			TriggerEvent("es:getPlayerFromId", tonumber(args[1]), function(user)
				TriggerEvent("serverlog", " Consolessa käytettiin /removerole komentoa pelaajaan " .. GetPlayerName(tonumber(args[1])))
				table.remove(args, 1)
				user.removeRole(table.concat(args, " "))
				TriggerClientEvent("chatMessage", user.get('source'), "SYSTEM", {255, 0, 0}, "A role was removed: ^2" .. table.concat(args, " "))
			end)

		CancelEvent()
	elseif commandName == 'setmoney' then
			if #args ~= 2 then
					RconPrint("Usage: setmoney [user-id] [money]\n")
					CancelEvent()
					return
			end

			if(GetPlayerName(tonumber(args[1])) == nil)then
				RconPrint("Player not ingame\n")
				CancelEvent()
				return
			end

			TriggerEvent("es:getPlayerFromId", tonumber(args[1]), function(user)
				if(user)then
					user.setMoney(tonumber(args[2]))
					TriggerEvent("serverlog", " Consolessa käytettiin /setmoney komentoa pelaajaan " .. GetPlayerName(tonumber(args[1])) .. " summana: " .. tonumber(args[2]))
					RconPrint("Money set")
					TriggerClientEvent('chatMessage', tonumber(args[1]), "CONSOLE", {0, 0, 0}, "Your money has been set to: ^2^*$" .. tonumber(args[2]))
				end
			end)

			CancelEvent()
		end
end)

-- Default commands
TriggerEvent('es:addCommand', 'admin', function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Level: ^*^2 " .. tostring(user.get('permission_level')))
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Group: ^*^2 " .. user.getGroup())
	TriggerEvent("serverlog", GetPlayerName(source) .. " käytti /admin komentoa")
end, {help = "Shows what admin level you are and what group you're in"})

-- Default commands
TriggerEvent('es:addCommand', 'report', function(source, args, user)
	TriggerClientEvent('chatMessage', source, "REPORT", {255, 0, 0}, " (^2" .. GetPlayerName(source) .." | "..source.."^0) " .. table.concat(args, " "))

	TriggerEvent("es:getPlayers", function(pl)
		for k,v in pairs(pl) do
			TriggerEvent("es:getPlayerFromId", k, function(user)
				if(user.getPermissions() > 0 and k ~= source)then
					TriggerClientEvent('chatMessage', k, "REPORT", {255, 0, 0}, " (^2" .. GetPlayerName(source) .." | "..source.."^0) " .. table.concat(args, " "))
				end
			end)
		end
	end)
end, {help = "Report a player or an issue", params = {{name = "report", help = "What you want to report"}}})

-- Append a message
function appendNewPos(msg)
	local file = io.open('resources/[essential]/es_admin/positions.txt', "a")
	newFile = msg
	file:write(newFile)
	file:flush()
	file:close()
end

-- Do them hashes
function doHashes()
  lines = {}
  for line in io.lines("resources/[essential]/es_admin/input.txt") do
  	lines[#lines + 1] = line
  end

  return lines
end


RegisterServerEvent('es_admin:givePos')
AddEventHandler('es_admin:givePos', function(str)
	appendNewPos(str)
end)

-- Noclip
TriggerEvent('es:addGroupCommand', 'noclip', "admin", function(source, args, user)
	TriggerClientEvent("es_admin:noclip", source)
	TriggerEvent("serverlog", GetPlayerName(source) .. " käytti /noclip komentoa")
	local data = {
		msg1 = 'Admin komento',
		msg2 = 'noclip',
	}
	
	TriggerEvent('discord:dmin', data)
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end, {help = "Enable or disable noclip"})

-- Kicking
TriggerEvent('es:addGroupCommand', 'kick', "admin", function(source, args, user)
	if args[1] then
		if(GetPlayerName(tonumber(args[1])))then
			local player = tonumber(args[1])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)

				local reason = args
				table.remove(reason, 1)
				table.remove(reason, 1)
				if(#reason == 0)then
					reason = "Kicked: You have been kicked from the server"
				else
					reason = "Kicked: " .. table.concat(reason, " ")
				end

				TriggerClientEvent('chatMessage', -1, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been kicked(^2" .. reason .. "^0)")
				TriggerEvent("serverlog", GetPlayerName(source) .. " käytti /kick komentoa pelaajaan " .. GetPlayerName(player) .. " syynä: " .. reason)
				DropPlayer(player, reason)
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Sinulla ei ole oikeuksia tähän!")
end, {help = "Kick a user with the specified reason or no reason", params = {{name = "userid", help = "The ID of the player"}, {name = "reason", help = "The reason as to why you kick this player"}}})

-- Announcing
TriggerEvent('es:addGroupCommand', 'announce', "admin", function(source, args, user)
	--table.remove(args, 1)
	TriggerClientEvent('chatMessage', -1, "Kaupunki tiedoittaa: ", {255, 0, 0}, "" .. table.concat(args, " "))
	TriggerEvent("serverlog", GetPlayerName(source) .. " Käytti /announce komentoa: "  .. table.concat(args, " "))
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Sinulla ei ole oikeuksia tähän!")
end, {help = "Announce a message to the entire server", params = {{name = "announcement", help = "Viesti jota haluat ilmoittaa kaupungin nimissä"}}})

-- Freezing
local frozen = {}
TriggerEvent('es:addGroupCommand', 'freeze', "admin", function(source, args, user)
	if args[1] then
		if(GetPlayerName(tonumber(args[1])))then
			local player = tonumber(args[1])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)

				if(frozen[player])then
					frozen[player] = false
				else
					frozen[player] = true
				end

				TriggerClientEvent('es_admin:freezePlayer', player, frozen[player])

				local state = "unfrozen"
				if(frozen[player])then
					state = "frozen"
				end

				TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have been " .. state .. " by ^2" .. GetPlayerName(source))
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been " .. state)
				TriggerEvent("serverlog", GetPlayerName(source) .. " käytti /freeze komentoa pelaajaan " .. GetPlayerName(player))
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Sinulla ei ole oikeuksia tähän!")
end, {help = "Freeze or unfreeze a user", params = {{name = "userid", help = "The ID of the player"}}})

-- Bring
local frozen = {}
TriggerEvent('es:addGroupCommand', 'bring', "admin", function(source, args, user)
	if args[1] then
		if(GetPlayerName(tonumber(args[1])))then
			local player = tonumber(args[1])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)

				TriggerClientEvent('es_admin:teleportUser', target.get('source'), user.getCoords().x, user.getCoords().y, user.getCoords().z)

				TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have brought by ^2" .. GetPlayerName(source))
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been brought")
				TriggerEvent("serverlog", GetPlayerName(source) .. " käytti /bring komentoa pelaajaan " .. GetPlayerName(player))
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end, {help = "Teleport a user to you", params = {{name = "userid", help = "The ID of the player"}}})

-- Bring
local frozen = {}
TriggerEvent('es:addGroupCommand', 'slap', "admin", function(source, args, user)
	if args[1] then
		if(GetPlayerName(tonumber(args[1])))then
			local player = tonumber(args[1])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)

				TriggerClientEvent('es_admin:slap', player)

				TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have slapped by ^2" .. GetPlayerName(source))
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been slapped")
				TriggerEvent("serverlog", GetPlayerName(source) .. " käytti /slap komentoa pelaajaan " .. GetPlayerName(player))
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end, {help = "Slap a user", params = {{name = "userid", help = "The ID of the player"}}})

-- Freezing
local frozen = {}
TriggerEvent('es:addGroupCommand', 'goto', "admin", function(source, args, user)
	if args[1] then
		if(GetPlayerName(tonumber(args[1])))then
			local player = tonumber(args[1])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)
				if(target)then

					TriggerClientEvent('es_admin:teleportUser', source, target.getCoords().x, target.getCoords().y, target.getCoords().z)

					TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have been teleported to by ^2" .. GetPlayerName(source))
					TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Teleported to player ^2" .. GetPlayerName(player) .. "")
					TriggerEvent("serverlog", GetPlayerName(source) .. " teleporttasi pelaajaan " .. GetPlayerName(player) .. " /goto komennolla")
				end
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end, {help = "Teleport to a user", params = {{name = "userid", help = "The ID of the player"}}})

-- Kill yourself
TriggerEvent('es:addCommand', 'die', function(source, args, user)
	TriggerClientEvent('es_admin:kill', source)
	TriggerClientEvent('chatMessage', source, "", {0,0,0}, "^1^*You killed yourself.")
	TriggerEvent("serverlog", GetPlayerName(source) .. " tappoi itsensä /die komennolla")
end, {help = "Suicide"})

-- Killing
TriggerEvent('es:addGroupCommand', 'slay', "admin", function(source, args, user)
	if args[1] then
		if(GetPlayerName(tonumber(args[1])))then
			local player = tonumber(args[1])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)

				TriggerClientEvent('es_admin:kill', player)

				TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "^0 Ylläpitäjä ^2" .. GetPlayerName(source) .."^0 tappoi sinut komennolla. Eikai sitä rikota sääntöjä?" )
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Pelaaja ^2" .. GetPlayerName(player) .. "^0 on tapettu.")
				TriggerEvent("serverlog", GetPlayerName(source) .. " tappoi " .. GetPlayerName(player) .. " /slay komennolla")
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end, {help = "Slay a user", params = {{name = "userid", help = "The ID of the player"}}})

-- Crashing
TriggerEvent('es:addGroupCommand', 'crash', "superadmin", function(source, args, user)
	if args[1] then
		if(GetPlayerName(tonumber(args[1])))then
			local player = tonumber(args[1])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)

				TriggerClientEvent('es_admin:crash', player)

				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been crashed.")
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end, {help = "Crash a user, no idea why this still exists", params = {{name = "userid", help = "The ID of the player"}}})

-- Position
TriggerEvent('es:addGroupCommand', 'pos', "admin", function(source, args, user)
	TriggerClientEvent('es_admin:givePosition', source)
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end, {help = "Save position to file"})

function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

loadBans()

RegisterNetEvent("serverlog")
AddEventHandler('serverlog', function(text)
	local gt = os.date('*t')
	local f,err = io.open("serverlog.log","a")
	if not f then return print(err) end
	local h = gt['hour'] if h < 10 then h = "0"..h end
	local m = gt['min'] if m < 10 then m = "0"..m end
	local s = gt['sec'] if s < 10 then s = "0"..s end
	local formattedlog = string.format("[%s:%s:%s] %s \n",h,m,s,text)
	f:write(formattedlog)
	f:close()
	-- uncomment line below, if you need (to show all logs in console also)
	print("Kirjoitettu logiin: " .. formattedlog)
end)

RegisterNetEvent("fcol")
AddEventHandler('fcol', function(text)
	local logFile,errorReason = io.open("fcoords.log","a")
	if not logFile then return print(errorReason) end
	local formattedLog = text
	logFile:write(formattedLog.."\n")
	logFile:close()
	-- Print to console
	print(formattedLog)
end)