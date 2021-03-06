local rocket_radius = tonumber(minetest.settings:get("rocket_launcher_radius")) or 3
minetest.register_chatcommand("rocket-radius", {
  description = "Set rocket explosion radius",
  params = "<number>",
  privs = {server=true},
  func = function(name, param)
    if not tonumber(param) then return false, 'Invalid value'
    else
    rocket_radius = tonumber(param)
    return true, 'Radius set to '..param
    end
end})
minetest.register_craftitem("rocket_launcher:rocket", {
	wield_scale = {x=1,y=1,z=1.5},
	description = "Rocket",
	inventory_image = "rocket.png",
})

minetest.register_tool("rocket_launcher:launcher", {
	wield_scale = {x=1,y=1,z=2},
	description = "Rocket Launcher",
	inventory_image = "rocket_launcher.png",
	on_use = function(itemstack, user, pointed_thing)
	local creative = minetest.check_player_privs(user:get_player_name(), {creative = true})
	local inv = user:get_inventory()
if inv:contains_item("main", "rocket_launcher:rocket") or creative then
if not creative then inv:remove_item("main", "rocket_launcher:rocket 1") end
		local pos = user:get_pos()
		local dir = user:get_look_dir()
		local yaw = user:get_look_horizontal()
		if pos and dir then
			pos.y = pos.y + 1.5
			local obj = minetest.add_entity(pos, "rocket_launcher:rocket")
			if obj then
				obj:setvelocity({x=dir.x * 30, y=dir.y * 30, z=dir.z * 30})
				obj:set_yaw(yaw)
			end
		end
		minetest.sound_play('rocket_launch',{to_player = name, gain=0.5})
		return itemstack
	end
end})

local rocket = {
	armor_groups = {immortal = true},
	physical = false,
	timer = 0,
	visual = "mesh",
	mesh = 'rocket.obj',
	visual_size = {x=0.7, y=0.7,},
	textures = {'rocket_mesh.png'},
	lastpos = {},
	pointable = false,
	collisionbox = {-0.25,-0.25,-0.25,0.25,0.25,0.25},
	--selectionbox = {-0.25,-0.25,-0.25,0.25,0.25,0.25},
	collide_with_objects = false,
	automatic_face_movement_dir = 270
}
rocket.on_step = function(self, dtime)
	self.timer = self.timer + dtime
	local pos = self.object:get_pos()
	local node = minetest.get_node(pos)
	local rnd = math.random()
	minetest.after(0.1,function()
	minetest.add_particle({
		pos = pos,
		velocity = {x=rnd,y=rnd,z=rnd},
		--acceleration = {x=rnd,y=rnd,z=rnd},
		expirationtime = 0.7,
		size = 10,
		collisiondetection = false,
		vertical = false,
		texture = "tnt_smoke.png",
		glow = 15,})end)

	if self.timer > 0.2 then
		local objs = minetest.get_objects_inside_radius({x = pos.x, y = pos.y-1, z = pos.z}, 1)
		for k, obj in pairs(objs) do
		if not obj then goto nodes end
		local prop = obj:get_properties()
		if not prop then goto nodes end
			if obj:is_player() or prop.collide_with_objects then
				tnt.boom(pos,{radius=rocket_radius})
				self.object:remove()
			end
		end
	end
::nodes::
	if self.lastpos.x ~= nil then
		if minetest.registered_nodes[node.name].walkable then
				tnt.boom(self.lastpos,{radius=rocket_radius})
			self.object:remove()
		end
	end
	self.lastpos= {x = pos.x, y = pos.y, z = pos.z}
end

minetest.register_entity("rocket_launcher:rocket", rocket)

minetest.register_craft({
	output = "rocket_launcher:rocket",
	recipe = {
		{"","default:steel_ingot",""},
		{"default:steel_ingot","default:mese_crystal","default:steel_ingot"},
		{"default:steel_ingot","tnt:gunpowder","default:steel_ingot"}
	}
})
minetest.register_craft({
	output = "rocket_launcher:launcher",
	recipe = {
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
		{"","default:mese_crystal","default:obsidian_block"},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"}
	}
})
