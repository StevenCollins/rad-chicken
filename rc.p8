pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- rad chicken
-- rubber chicken studios
function _init()
 -- set transparency.
	palt(0,false)
	palt(15,true)
	
	make_chicken()
	make_ground()
	make_obstacles()
end

function _update()
 move_ground()
 move_chicken()
 move_obstacles()
end

function _draw()
	-- clear screen to bg colour.
	cls(13)
	-- draw everything else.
	draw_ground()
	draw_chicken()
	draw_obstacles()
end
-->8
-- chicken
-- init constants.
ground_level=81
gravity=0.4
jump_power=1
jump_length=9
c_sprites={
		{ 0, 0, 2, 3, 4, 0},
		{ 0,17,18,19,20, 0},
		{ 0,33,34,35,36, 0},
		{48,49,50,51,52,53},
		{64,65,66,67,68,69}}

function make_chicken()
	c={}
	c.x=2
	c.y=ground_level
	c.dx=0
	c.dy=0
	c.bump_offset=0
	c.update_bump=true
	c.jump_frame=0
end

function move_chicken()
	c.dy+=gravity
	
	-- do jump.
	if ((
				-- check on the ground,
				btn(🅾️) and
				c.y==ground_level and
				c.jump_frame==0
			) or (
				-- or still jumping. 
				btn(🅾️) and
				c.jump_frame>0 and
				c.jump_frame<jump_length
			)) then
		c.dy-=jump_power
		c.jump_frame+=1
	else
		c.jump_frame=0
	end
	
	-- do move.
	c.y+=c.dy
	-- don't fall through the ground.
	-- the ground kills velocity.
	if (c.y>ground_level) then
		c.y=ground_level
		c.dy=0
	end
end

function draw_chicken()
 -- make it bumpy on the ground.
 -- set 0 or 1px y offset every other frame.
 if (c.y==ground_level) then
		c.update_bump=not c.update_bump
		if (c.update_bump) do
			c.bump_offset = flr(rnd(2))
		end
	end
	-- do wheel animation.
	c_sprites[5][2]=rnd({65,81})
	c_sprites[5][5]=rnd({68,84})
	-- draw chicken sprites.
	for y, row in ipairs(c_sprites) do
		for x, sprite in ipairs(row) do
			if (sprite>0) then -- don't draw empty sprites.
				-- calculate offset for jump animation.
				jump_offset=0
				if (c.jump_frame > 0 and x>7-c.jump_frame) then
					jump_offset=c.jump_frame-6+x
				end
				-- actually draw a sprite.
				spr(sprite,c.x+x*8-8,c.y+y*8-8+c.bump_offset-jump_offset)
			end
		end
	end
end
-->8
-- ground
-- init constants.
ground_sprites={7,8,9,10}
ground_speed=2

function make_ground()
	g={}
	g.sprites={}
	g.step=0 -- pixel offset for animation.

	-- for the width of the screen plus 1 sprites,
	-- select a random ground sprite.
	for i=1,17 do
		g.sprites[i]=rnd(ground_sprites)
	end
end

function move_ground()
	-- increment or reset step counter.
	g.step=(g.step+ground_speed)%8
	-- if we just reset...
	if (g.step==0) then
		-- add new sprite,
		add(g.sprites,rnd(ground_sprites))
		-- remove first sprite.
		del(g.sprites,g.sprites[1])
	end
end

function draw_ground()
	for i, sprite in ipairs(g.sprites) do
		spr(sprite,i*8-8-g.step,120)
	end
end
-->8
-- obstacles
-- init constants.
obstacle_sprites={
	{{22}},
	{{23,24}},
	{{38,39},
	 {54,55}}
}
obstacle_overhang=2 -- leftside buffer so onscreen obstacles don't disappear.

function make_obstacles()
 -- bit of a misnomer,
 -- obstacles are made in move.
 o={}
	for i=1,17+obstacle_overhang do
		o[i]=0
	end
	
	o[#o]=3 -- test obstacle
end

function move_obstacles()
	if (g.step==0) then -- obstacles follow the ground.
		new_obstacle=0
		-- add new obstacle,
		add(o,new_obstacle)
		-- remove first obstacle.
		del(o,o[1])
	end
end

function draw_obstacles()
	for i, obstacle in ipairs(o) do
		if (obstacle!=0) then
			-- get obsticle sprite table.
			ost=obstacle_sprites[obstacle]
			-- draw sprites in ost.
			for y, row in ipairs(ost) do
				for x, sprite in ipairs(row) do
					if (sprite>0) then -- don't draw empty sprites.
						spr(sprite,i*8+x*8-8*obstacle_overhang-8-g.step,113-#ost*8+y*8)
					end
				end
			end
		end
	end
end
__gfx__
0000000000000000ffffffff00000000ffffffff0000000000000000fbbffbffffbffbbfffbf33bff33bfbff0000000000000000000000000000000000000000
0000000000000000ffffffff0000000000ffffff0000000000000000333333333333333333334333334333330000000000000000000000000000000000000000
0000000000000000ffffffff008888880000ffff0000000000700700444444444444444444444444444444440000000000000000000000000000000000000000
0000000000000000ffffffff008888888800ffff0000000000077000444444444444444444444444444444440000000000000000000000000000000000000000
0000000000000000ffffffffff000088888800ff0000000000077000444444444444444444444444444444440000000000000000000000000000000000000000
0000000000000000fffffff22222e2222222e22f0000000000700700444444444444444444444444444444440000000000000000000000000000000000000000
0000000000000000fffffff222222e2222222e2f0000000000000000444444444444444444444444444444440000000000000000000000000000000000000000
0000000000000000ffffffff007722e2222222ef0000000000000000444444444444444444444444444444440000000000000000000000000000000000000000
00000000ff0000ffffffffff0077722e2299990000000000ffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000
00000000ff0000ffffffffff00777722e799990000000000ffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000
000000000077770000ffffff00777777777700ff00000000ffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000
000000000077770000ffffff00777777777700ff00000000fff55fffff444444444444ff00000000000000000000000000000000000000000000000000000000
00000000007777777700000077777777777700ff00000000ff5665fff44444444444044f00000000000000000000000000000000000000000000000000000000
00000000007777777700000077777777777700ff00000000ff56665ff44440444044404f00000000000000000000000000000000000000000000000000000000
000000000077777777777777777777777777770000000000f566665ff44044444444444f00000000000000000000000000000000000000000000000000000000
000000000077777777777777777777777777770000000000f555555fff444444444044ff00000000000000000000000000000000000000000000000000000000
00000000ff00777777777777777777777777770000000000fffffff11fffffff0000000000000000000000000000000000000000000000000000000000000000
00000000ff00777777777777777777777777770000000000fffffff11fffffff0000000000000000000000000000000000000000000000000000000000000000
000000000077777777777777777777777777770000000000ffffff1111ffffff0000000000000000000000000000000000000000000000000000000000000000
000000000077777777777777777777777777770000000000ffffff1111ffffff0000000000000000000000000000000000000000000000000000000000000000
000000000077777777777777777777777777770000000000fffff1f11f1fffff0000000000000000000000000000000000000000000000000000000000000000
000000000077777777777777777777777777770000000000fffff1f11f1fffff0000000000000000000000000000000000000000000000000000000000000000
00000000ff00777777777777777777777777770000000000ffff1ff11ff1ffff0000000000000000000000000000000000000000000000000000000000000000
00000000ff00777777777777777777777777770000000000ffff1ff11ff1ffff0000000000000000000000000000000000000000000000000000000000000000
ffffffffffff00777777777777777777777700fffffffffffff1fff11fff1fff0000000000000000000000000000000000000000000000000000000000000000
ffffffffffff00777777777777777777777700fffffffffffff1ff1ff1ff1fff0000000000000000000000000000000000000000000000000000000000000000
ffffffffffffff0000777777777777770000ffffffffffffff1ff1ffff1ff1ff0000000000000000000000000000000000000000000000000000000000000000
ffffffffffffff0000007777777777770000ffffffffffffff1f1ffffff1f1ff0000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffff00990000000000fffffffffffffffff1f1ffffffff1f1f0000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffff00990000000000fffffffffffffffff11ffffffffff11f0000000000000000000000000000000000000000000000000000000000000000
ff000fffffffffffff00999999009900ffffffffffff000f11ffffffffffff110000000000000000000000000000000000000000000000000000000000000000
f033b0ffffffffffff00999999009900fffffffffff0bbb011111111111111110000000000000000000000000000000000000000000000000000000000000000
f0333b0000000000000000000000000000000000000bbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff0333b3b3bbb3bbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbb0f00000000000000000000000000000000000000000000000000000000000000000000000000000000
fff0333333333333333333333333333333333333333330ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
ffff00000000000000000000000000000000000000000fff00000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffffff088e0fffffffffffffffffffff088e0ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffffff08080fffffffffffffffffffff08080ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffffff08880fffffffffffffffffffff08880ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffff000fffffffffffffffffffffff000fffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b3bbb3bb0000000000000000bbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333330000000000000000333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000f08880ff0000000000000000fff088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000f08080ff0000000000000000fff080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000f0e880ff0000000000000000fff0e8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ff000fff0000000000000000ffff000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddd00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddd0000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddd008888880000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddd008888888800dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddd000088888800dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddd22222e2222222e22ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddd222222e2222222e2ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddd007722e2222222eddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddd0000dddddddddd0077722e22999900dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddd0000dddddddddd00777722e7999900dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddd0077770000dddddd00777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddd0077770000dddddd00777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddd007777777700000077777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddd007777777700000077777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddd00777777777777777777777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddd00777777777777777777777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddd007777777777777777777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddd007777777777777777777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddd00777777777777777777777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddd00777777777777777777777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddd00777777777777777777777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddd00777777777777777777777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddd007777777777777777777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddd007777777777777777777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddd00777777777777777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddd00777777777777777777777700dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddd0000777777777777770000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddd0000007777777777770000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddd00990000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddd00990000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddd000ddddddddddddd00999999009900dddddddddddd000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddd033b0dddddddddddd00999999009900ddddddddddd0bbb0dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddd0333b0000000000000000000000000000000000000bbbb0dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddd0333b3b3bbb3bbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbb0ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddd0333333333333333333333333333333333333333330dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddd00000000000000000000000000000000000000000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddd08880ddddddddddddddddddddd08880dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddd08080ddddddddddddddddddddd08080dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
bdd33bdbdddbbddbd08880dbddddbd33bdddbddbbdd08880bdd33bdbddd33bdbdddbbddbdddbbddbddddbd33bdd33bdbddddbddbbddbbddbddddbddbbdddbddb
33334333333333333300033333333343333333333333000333334333333343333333333333333333333333433333433333333333333333333333333333333333
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
