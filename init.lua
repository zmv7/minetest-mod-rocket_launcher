local rocket_radius = tonumber(minetest.settings:get("rocket_launcher_radius")) or 3

minetest.register_craftitem("rocket_launcher:launcher", {
	description = "Rocket Launcher",
	inventory_image = "rocket_launcher.png",
	on_use = function(itemstack, user, pointed_thing)
		local pos = user:getpos()
		local dir = user:get_look_dir()
		local yaw = user:get_look_horizontal()
		if pos and dir then
			pos.y = pos.y + 1.5
			local obj = minetest.add_entity(pos, "rocket_launcher:rocket")
			if obj then
				obj:setvelocity({x=dir.x * 30, y=dir.y * 30, z=dir.z * 30})
				obj:setyaw(yaw)
			end
		end
		return itemstack
	end,
})

local rocket = {
	armor_groups = {immortal = true},
	physical = false,
	timer = 0,
	visual = "mesh",
	mesh = 'rocket.obj',
	visual_size = {x=0.7, y=0.7,},
	textures = {'rocket.png'},
	lastpos = {},
	pointable = false,
	collisionbox = {-0.25,-0.25,-0.25,0.25,0.25,0.25},
	--selectionbox = {-0.25,-0.25,-0.25,0.25,0.25,0.25},
	collide_with_objects = false,
}
rocket.on_step = function(self, dtime)
	self.timer = self.timer + dtime
	local pos = self.object:getpos()
	local node = minetest.get_node(pos)

	if self.timer > 0.2 then
		local objs = minetest.get_objects_inside_radius({x = pos.x, y = pos.y-1, z = pos.z}, 1)
		for k, obj in pairs(objs) do
		if not obj then goto nodes end
			if obj:is_player() then
				tnt.boom(pos,{radius=rocket_raduis})
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
