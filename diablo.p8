pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- entity

entity = {}
entity.__index = entity

function entity:init(x, y, sprite)
	local self = setmetatable({}, entity)
	self.x = x or 0
	self.y = y or 0
	self.speed = 1
	self.sprite = sprite or 0
	self.health = 0
	self.is_dead = false
	return self
end

function entity:draw()
	if not self.is_dead then
		spr(self.sprite, self.x, self.y)
	end
end

function entity:update()
	self:check_death()
end

function entity:check_death()
	if self.health <= 0 then
		self.is_dead = true
	end
end


direction = {
	left = 0,
	right = 1,
	down = 2,
	up = 3,
}

function entity:move(d)
	if d == direction.left then
		self.x -= self.speed
	elseif d == direction.right then
		self.x += self.speed
	elseif d == direction.down then
		self.y -= self.speed
	elseif d == direction.up then
		self.y += self.speed
	end
end

function entity:hit(damage)
	self.health -= damage
end

function entity:is_colliding(entity)
	return (abs(self.x-entity.x)+
	abs(self.y-entity.y)) <= 8
end



-->8
-- player

player = {}
player = setmetatable(player, {__index = entity})
player.__index = player

function player:init(x, y)
	local self = setmetatable(entity:init(x, y, 1), player)
	self.health = 100
	self.inventory = {}
	self.equipment = {}
	return self
end

function player:draw()
	entity.draw(self)
	self:draw_inventory()
end

function player:update()
	if btn(direction.left) then
		self:move(direction.left)
	end
	if btn(direction.right) then
		self:move(direction.right)
	end
	if btn(direction.down) then
		self:move(direction.down)
	end
	if btn(direction.up) then
		self:move(direction.up)
	end
end

function player:add_item(item)
	add(self.inventory, item)
end

function player:equip(item, slot)
	self.equipments[slot] = item
end

function player:draw_inventory()
	rect(80, 80, 125, 120, 7)
	print("inventory", 84, 84)
	for item in all(self.inventory) do
		print(item.name, 84, 92)
	end
end

-->8
-- foe


foe = {}
foe.__index = foe
setmetatable(foe, {__index = entity})

function foe:init(x, y)
	local self = setmetatable(entity:init(x, y, 2), foe)
	self.atttack = 3
	self.health = 10
	return self
end

function foe:attack(target)
	if target.health > 0 then
		target.hp -= self.attack
	end
end

function foe:update()
	entity.update(self)
	if self:is_colliding(player) then
		self:hit(1)
	end
end
-->8
-- item

equipment_slot = {
	head=0,
	torso=1,
	leg=2,
	boots=3,
	weapon=4,
}

item = {}
item.__index = item

function item:init(name, sprite)
	local self = setmetatable({}, item)
	self.name = name
	self.sprite = sprite or 0
	self.x = 30
	self.y = 30
	return self
end

function item:draw()
	spr(self.sprite, 30, 30)
end

function item:update()
	if self:is_colliding(player) then
		world:player_looted_item(self)
	end
end

function item:is_colliding(entity)
	return (abs(entity.x-self.x)+
	abs(entity.y-self.y)) <= 8
end

weapon = {}
weapon = setmetatable(weapon, {__index = item})
weapon.__index = weapon

function weapon:init(name, attack)
	local self = setmetatable(item:init(name, 0), weapon)
	self.attack = attack
	self.slot = equipment_slot.weapon
	return self
end

armor= {}
armor = setmetatable(armor, {__index = item})
armor.__index = armor

function armor:init(name, defense, slot)
	local self = setmetatable(item:init(name, 0), armor)
	self.defense = defense
	self.slot = slot
	return self
end


-->8
-- world

world = {}
world.__index = world

function world:init()
	local self = setmetatable({}, world)
	world.items = {}
	world.foes = {}
	return self
end

function world:draw()
	for item in all(self.items) do
		item:draw()
	end

	for foe in all(self.foes) do
		foe:draw()
	end
end


function world:update()
	for item in all(self.items) do
		item:update()
	end

	for foe in all(self.foes) do
		foe:update()
	end
end

function world:spawn_item(item)
	add(self.items, item)
end

function world:spawn_foe(foe)
	add(self.foes, foe)
end

function world:player_looted_item(item)
		player:add_item(item)
		del(self.items, item)
end
-->8
-- engine

state = {
	game = 1,
	inventory = 2
}


function _init()
	current_state = state.game
	world = world:init()
	player = player:init(64, 64)
	world:spawn_item(weapon:init("sword", 0))
	world:spawn_foe(foe:init(10, 10))
end

function _draw()
	cls()
	player:draw()
	world:draw()
end

function _update60()
	if current_state == state.game then
		player:update()
		world:update()
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000100000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
