pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- rad chicken
-- rubber chicken studios

-- constants.
cartdata("rad_chicken")
bg_colour=1
trans_colour=15
game_speed=1

function _init() title_init() end

function title_init()
	_update60=title_update
	_draw=title_draw
	
	poke(0x5f5c, 255) -- disable btnp repeat.
	
	cntr=0 -- just a counter that increases every frame.
	
	fast() -- set initial speed and create pause menu item.
	-- create pause menu item.
	menuitem(2,"reset highscore",
			function()
				dset(0,0)
				highscore=0
			end
	)
	
	-- set transparency.
	palt(0,false)
	palt(trans_colour,true)
end

function fast()
	game_speed=2
	cntr+=cntr%2 -- make cntr even to avoid bugs.
	menuitem(1,"slooow dooown",slow)
end

function slow()
	game_speed=1
	menuitem(1,"gotta go fast",fast)
end

function title_update()
	if (btnp()>0) then -- start game.
		game_init()
 end
end

function title_draw()
	-- funky bg.
	for i=0,127 do
		line(0,i,127,i,rnd({0,1,2,3,5}))
	end
	
	-- draw chicken.
	map(0,0,40,20,6,5)
	
	-- draw text.
	local offset=76
	print("rad chicken",42,offset,7)
	offset+=8
	print("🅾️/z to jump",40,offset,7)
	offset+=8
	print("❎/x to hover",38,offset,7)
	offset+=8
	print("⬆️ or ⬇️ for tricks",26,offset,7)
	offset+=8
	print("any button to start",26,offset,7)
end

function game_init()
	_update60=game_update
	_draw=game_draw
	
	-- game state.
	game_over=false
	points=0 -- holds points for most recent trick.
	score=0 -- total points scored.
	highscore=dget(0) -- get highscore from cart data.
	
	-- init all the things!
	make_chicken()
	make_ground()
	make_obstacles()
end

function game_update()
	cntr+=game_speed -- increase the counter.
	if (not game_over) then
	 move_ground()
	 move_chicken()
	 move_obstacles()
	elseif (btnp(❎)) then -- reset game.
		_init()
 end
end

function game_draw()
	if (not game_over) then
		-- clear screen to bg colour.
		cls(bg_colour)
		-- draw everything.
		draw_ground()
		draw_chicken()
		draw_obstacles()
	end
	
	draw_overlay()
	
	-- print(stat(1),0,124,0) -- cpu usage.
	-- print(cntr,0,124,0) -- cntr value.
end

-- 0 to 7 counter.
function step()
	return cntr%8
end

-- 0 to x counter, game_speed dependant.
function step_x(x)
	return (cntr/game_speed)%x
end
-->8
-- chicken
-- init constants.
g_level=83
gravity=0.2
jump_power=0.5
jump_length=10 -- number of frames the jump button works for.
float_length=30 -- number of float frames.
float_regen=8 -- frames per float point.
tt_length=30 -- number of frames trick text appears for.
tt_pre={"rad","awe","tube","cowab"}
tt_suf={"ical","some","ular","unga"}

c_sprites={ -- default sprite.
		{ 0, 0, 1, 2, 3, 0},
		{ 0,16,17,18,19, 0},
		{ 0,32,33,34,35, 0},
		{36,48,49,50,51,41},
		{52,53,54,55,56,57}}
c_1_sprites={ -- redbull frames.
		{{ 0,  0, 65, 66, 67, 0},
		 { 0, 80, 81, 82, 83, 0},
		 { 0, 96, 97, 98, 99, 0},
		 {36,112,113,114,115,41},
		 {52, 53, 54, 55, 56,57}},
		{{ 0, 68, 69, 70, 71, 0},
		 { 0, 84, 85, 86, 87, 0},
		 { 0,100,101,102,103, 0},
		 {36,116,117,118,119,41},
		 {52, 53, 54, 55, 56,57}}}
c_1_sprites_list={1,1,1,1,2,2,2,2} -- redbull frame order.
c_1_sprites_list_b={1,1,2,2} -- float frame order.
c_2_sprites={ -- jackson frames.
		{{ 0,  0, 73, 74, 75, 0},
		 { 0, 88, 89, 90, 91, 0},
		 { 0,104,105,106,107, 0},
		 {36,120,121,122,123,41},
		 {52, 53, 54, 55, 56,57}},
		{{ 0,  0, 77, 78, 79, 0},
		 { 0, 92, 93, 94, 95, 0},
		 { 0,108,109,110,111, 0},
		 {36,124,125,126,127,41},
		 {52, 53, 54, 55, 56,57}}}
c_2_sprites_list={1,1,2,2} -- jackson frame order.
l_w_sprites={37,53} -- left wheel sprites.
r_w_sprites={40,56} -- right wheel sprites.

function make_chicken()
	c={}
	c.x=2
	c.y=g_level
	c.dx=0
	c.dy=0
	c.bump_offset=0
	c.jump_frame=0
	c.spriteset=c_sprites
	c.trickd=false -- performed trick?
	c.tt="" -- trick text.
	c.tt_cntr=0 -- counter for trick text.
	c.ab_cntr=0 -- length of time airborne.
	c.o_jumped=0 -- track the obstacle jumped.
	c.float_cntr=0 -- track time floating.
end

function move_chicken()
	-- tricks.
	if (btn(❎) and c.y<g_level and c.float_cntr<float_length) then -- float.
		if (c.trickd==false) then
			sfx(2) -- only play for new trick.
		end
		c.spriteset=c_1_sprites[c_1_sprites_list_b[(step_x(#c_1_sprites_list_b))+1]]
		c.dy=0 -- stop vertical movement.
		c.float_cntr+=1
		c.trickd=true
	elseif (btn(⬆️)) then -- redbull.
		if (c.trickd==false) then
			sfx(2) -- only play for new trick.
		end
		c.spriteset=c_1_sprites[c_1_sprites_list[(step_x(#c_1_sprites_list))+1]]
		c.dy+=gravity/2
		c.trickd=true
	elseif (btn(⬇️)) then -- jackson.
		if (c.trickd==false) then
			sfx(3) -- only play for new trick.
		end
		c.spriteset=c_2_sprites[c_2_sprites_list[(step_x(#c_2_sprites_list))+1]]
		c.dy+=gravity*2
		c.trickd=true
	else -- no tricks.
		c.spriteset=c_sprites
		c.dy+=gravity
	end
	
	-- slowly regen float.
	if(step_x(float_regen)==0 and c.float_cntr>0) then
			c.float_cntr-=1
	end
	
	-- do jump.
	if ((
				-- check on the ground,
				btn(🅾️) and
				c.y>=g_level and
				c.jump_frame==0
			) or (
				-- or still jumping. 
				btn(🅾️) and
				c.jump_frame>0 and
				c.jump_frame<jump_length
			)) then
		c.dy-=jump_power
		c.jump_frame+=1
		sfx(0)
	else
		c.jump_frame=0
	end
	
	-- track the obstacle in the jump zone.
	for o_y=10,15 do -- can only jump over obstacles between 10 and 15 y.
		for o_x=2+o_overhang,4+o_overhang do -- skateboard is roughly between 2 and 4.
			if (o[o_y][o_x]!=0) then
				c.o_jumped=o[o_y][o_x]
			end
		end
	end
	
	-- do move. gravity and airborne cntr always happen.
	c.y+=c.dy
	c.ab_cntr+=1
	
	-- landed a trick.
	if (c.y>=g_level and c.tt_cntr==0 and c.o_jumped!=0) then
		c.trickd=false
		-- calculate points, show trick text if good, and add points to score.
		points=100-c.ab_cntr+o_bonus[c.o_jumped]
		if (points>40) then
			c.tt=rnd(tt_pre)..rnd(tt_suf)
		end
		if (points>0) then
			score+=points
		end
	end
	-- trick text maintenance.
	if (c.tt!="" and c.tt_cntr<=tt_length) then
		c.tt_cntr+=1
	elseif (c.tt_cntr>=tt_length) then
		c.tt=""
		c.tt_cntr=0
	end

	-- on the ground.
	if (c.y>=g_level) then
		c.y=g_level -- don't fall through it.
		c.dy=0 -- stop trying to fall through it.
		c.ab_cntr=0 -- not airborne.
		c.o_jumped=0 -- not jumping an obstacle.
	end
end

function draw_chicken()
	-- bumpy! set 0 or 1px y offset every 4 frames.
	if (c.y==g_level) then -- on the ground?
		if (step_x(4)==0) do
			c.bump_offset=flr(rnd(2))
		end
	else
		c.bump_offset=0 -- no offset in the air.
	end
	-- do wheel animation every 4 frames.
	if (step_x(4)==0) then
		c_sprites[5][2]=rnd(l_w_sprites)
		c_sprites[5][5]=rnd(r_w_sprites)
	end
	-- draw chicken sprites.
	for spr_y, row in ipairs(c.spriteset) do
		for spr_x, sprite in ipairs(row) do
			if (sprite>0) then -- don't draw empty sprites.
				-- calculate offset for jump animation.
				jump_offset=0
				if (c.jump_frame > 0 and spr_x>7-c.jump_frame) then
					jump_offset=c.jump_frame-6+spr_x
				end
				-- actually draw a sprite.
				spr(sprite,c.x+spr_x*8-8,c.y+spr_y*8-8+c.bump_offset-jump_offset)
			end
		end
	end
end
-->8
-- ground,bg,overlay
-- init constants.
g_sprites={20,21,22,23}

function make_ground()
	-- init ground.
	g={}
	g.sprites={}
	-- for the width of the screen plus 1 sprites,
	-- select a random ground sprite.
	for i=1,17 do
		g.sprites[i]=rnd(g_sprites)
	end
	
	-- init background layers.
	layers={}
	layers.pyramin={x=0,spd=0.5,w=127}
	layers.pyramax={x=0,spd=0.25,w=256}
	layers.sun={x=50,spd=0.005,w=127,y=30}
	layers.swoosh={x=0,spd=0.15,w=256}
	layers.swoosh2={x=256,spd=layers.swoosh.spd,w=layers.swoosh.w}
	layers.trees={x=0,spd=1,w=64,rndx=256}
	layers.trees2={x=96,spd=1,w=64,rndx=256}
end

function move_ground()
	-- if we just hit the 8px boundary...
	if (step()==0) then
		-- add new sprite,
		add(g.sprites,rnd(g_sprites))
		-- and remove first sprite.
		del(g.sprites,g.sprites[1])
	end
	
	-- moves each layer by its speed, and kills it when it's gone too far.
	for i,layer in pairs(layers) do
		layer.x-=layer.spd
		if (layer.x<-1*layer.w) then
			layer.x=128
			if (layer.rndx!=nil) then
				layer.x+=rnd(layer.rndx)
			end
		end
	end
end

function draw_ground()
	-- draw the swoosh image but stretched
	sspr(0,120,32,8,layers.swoosh.x,-24,256,64)
	-- draw the second swoosh.
	sspr(0,120,32,8,layers.swoosh2.x,-24,256,64)
	-- draw the sun.
	circfill(layers.sun.x,layers.sun.y,16,14)
	circfill(layers.sun.x,layers.sun.y,13,1)
	circfill(layers.sun.x,30,11,8)
	circ(layers.sun.x,layers.sun.y,16,6)
	circ(layers.sun.x,layers.sun.y,14,2)
	circ(layers.sun.x,30,11,2)
	-- draw sunglasses on the sun.
	spr(38,layers.sun.x-5,25,2,1)
	-- draw the pyramids.
	map(57,0,layers.pyramax.x,24,32,16)
	map(40,0,layers.pyramin.x,64,16,8)
	-- draw the palm trees.
	sspr(64,96,32,32,layers.trees.x,62,64,64)
	sspr(96,96,32,32,layers.trees2.x,62,64,64)
 
	if (step_x(4)==0) do
		layers.sun.y=flr(29+rnd(3))
	end

	for i,sprite in ipairs(g.sprites) do
		spr(sprite,i*8-8-step(),120)
	end
end

function draw_overlay()
	if (not game_over) then
		print(highscore,7)
		print(score,7)
		print(points,7)
		-- draw float cntr.
		rect(125-float_length,0,127,6,7)
		if (c.float_cntr>float_length*(3/4)) then
			rectfill(126-float_length+c.float_cntr,1,126,5,8)
		else
			rectfill(126-float_length+c.float_cntr,1,126,5,7)
		end
		-- draw trick text.
		if (c.tt) then
			print(c.tt,c.x+32+c.tt_cntr,c.y-c.tt_cntr,rnd(16))
		end
	else
		local rnd_colour=rnd(16)
		local offset=24
		print("game over",46,offset,rnd_colour)
		offset+=8
		print("your score:"..score,38,offset,rnd_colour)
		offset+=8
		print("high score:"..highscore,38,offset,rnd_colour)
		offset+=8
		if (score>highscore) then
			print("you're rad!!!!!",34,offset,rnd_colour)
			offset+=8
		end
		print("press ❎ to play again",20,offset,rnd_colour)
	end
end
-->8
-- obstacles
-- init constants.
o_sprites={ -- table{obstacle{frame{row{sprite}}}}.
	{{{60}},{{61}}},
	{{{4,5}},{{6,7}}},
	{{{12},
	  {28},
	  {44}},
	 {{13},
	  {29},
	  {45}},
	 {{14},
	  {30},
	  {46}}},
	{{{10,11},
	  {26,27}},
	 {{42,43},
	  {58,59}},
	 {{ 8, 9},
	  {24,25}}}}
o_sprites_list={ -- table{obstacle{frame}}.
	{1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2},
	{1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2},
	{1,1,1,1,2,2,2,2,3,3,3,3,2,2,2,2},
	{1,1,1,1,2,2,2,2,3,3,3,3,2,2,2,2}}
o_g_obstacles={1,2,3} -- ground obstacles.
o_f_obstacles={4} -- flying obstacles.
o_f_chance=0.2 -- chance for obstacle to be flying.
o_bonus={0,10,20,50} -- bonus points for each obstacle.
o_overhang=2 -- leftside buffer so onscreen obstacles don't disappear.
o_offset=5 -- push obstacles slightly into ground.
o_cntdn_min=16 -- minimum spritewidths until next obstacle.
o_cntdn_max=30 -- maximum ...
o_height_min=2 -- minimum obstacle height (rows from top).
o_height_max=13 -- maximum ...

function make_obstacles()
 -- bit of a misnomer, obstacles are made in move.
 -- this initializes the obstacle tables.
 o={}
 for y=1,16 do
 	o[y]={}
		for x=1,16+o_overhang do
			o[y][x]=0
		end
	end
	
	-- countdown to next obstacle.
	o_cntdn=o_cntdn_min
end

function move_obstacles()
	-- if we just hit the 8px boundary...
	if (step()==0) then
		o_cntdn-=1
		new_obstacle=0
		if (o_cntdn==0) then -- time for new obstacle!
			o_cntdn=flr(rnd(o_cntdn_max-o_cntdn_min)-(cntr/2000))+o_cntdn_min -- reset the countdown.
			-- choose a new obstacle.
			if (rnd()<o_f_chance) then -- flying obstacle.
				new_obstacle=rnd(o_f_obstacles)
				new_obstacle_y=flr(rnd(o_height_max))+o_height_min
			else -- ground obstacle.
				new_obstacle=rnd(o_g_obstacles)
				new_obstacle_y=15 -- ground height.
			end
		end
		-- add the new obstacle at the right height.
		for i=1,16 do
			if (i==new_obstacle_y) then
				add(o[i],new_obstacle)
			else
				add(o[i],0)
			end
			del(o[i],o[i][1]) -- shift obstacles left.
		end
	end
end

function draw_obstacles()
	for obs_y, obs_row in ipairs(o) do
		for obs_x, obstacle in ipairs(obs_row) do
			if (obstacle!=0) then
				-- get correct frame from the obstacle sprite table.
				ost=o_sprites[obstacle][o_sprites_list[obstacle][flr(step_x(#o_sprites_list[obstacle]))+1]]
				-- draw sprites in ost.
				for spr_y, row in ipairs(ost) do
					for spr_x, sprite in ipairs(row) do
						if (sprite>0) then -- don't draw empty sprites.
							local x=o_x_pos(obs_x,spr_x)
							local y=o_y_pos(obs_y,spr_y)
							if (detect_collision(sprite,x,y)) then
								die()
							end
							spr(sprite,x,y)
						end
					end
				end
			end
		end
	end
end

function o_x_pos(obs_x,spr_x)
	return
			obs_x*8 -- obstacle x position within screen.
			+spr_x*8 -- sprite x position within obstacle.
			-o_overhang*8 -- offset left for overhang.
			-8	-- arrays should start at 0.
			-step() -- offset for scrolling animation.
end

function o_y_pos(obs_y,spr_y)
	return
			obs_y*8 -- obstacle y position within screen.
			+spr_y*8 -- sprite y position within obstacle.
			-#ost*8 -- top of sprite first, so go up by sprite height.
			+o_offset -- offset obstacles slightly into ground.
			-8	-- arrays should start at 0.			
end

-- detect collision by checking if any pixels to be drawn over are already a non-bg colour.
function detect_collision(sprite,x,y)
	for pxl_y=0,7 do
		for pxl_x=0,7 do
			if (x+pxl_x>0 and x+pxl_x<64 and y+pxl_y<120) then -- is the obstacle where the chicken could be?
				if (sget((sprite%16)*8+pxl_x,flr(sprite/16)*8+pxl_y)!=trans_colour) then -- is the obstacle not transparent on the pixel we're checking?
					if (pget(x+pxl_x,y+pxl_y)==0) then -- check if the colour is black? seems kinda racist bud.
						return true -- then it's a collision.
					end
				end
			end
		end
	end
	return false
end

function die()
	game_over=true
	sfx(1)
	if (score>highscore) then
		dset(0,score)
	end
end
__gfx__
ffffffffffffffff00000000ffffffffaddfff0f0fffaddfffffffffffffffffffffffffffffffffffffffffffff6666fbb33fffffffffffffffffffffffffff
ffffffffffffffff0000000000ffffffffdfff5055ffffdfffffff00055fffffffff66666fffffffffffff666f666776ffbf378ffbb33fffffffffffffffffff
ffffffffffffffff008888880000ffffaddff5a9a98faddfcddff5a9a98ffcddff66777666666666ffff666766667676ff3f3fbfff3f388ffbb3333fffffffff
ffffffffffffffff008888888800ffffffdff599998fffdfffdff599998ffffdff67676677677676fff6677766677776bfbf3f3fffbf3fbffbb33b3fffffffff
ffffffffffffff000000008888880000ffdf588888888fdfcddf588888888cdd0000006776777766ff66767666776766bf3833bfbf33333ffb3333bfffffffff
ffffffffffffff022222e2222222e220ffdd588888888ddfffdd588888888ffd0000000666666660ff6777667776776ffbb733bffbb833bffbb3333fffffffff
ffffffffffffff0222222e2222222e20ffff888855555fffffff888855555ddd05555555555555500000006777777660ff3833ffff373bffff3833ffffffffff
ffffffffffffff00007722e2222222e0ffff555555555fffffff555555555fff05500005500005500000000666666600fff333fffff83bfffff733ffffffffff
ff0000ffffffffff0077722e2299990ffbbffbffffbffbbfffbf33bff33bfbff05066660066660500555555555555550fffb33fffffb33fffff833ffffffffff
ff0000ffffffffff00777722e799990f3333333333333333333343333343333305060060060060500550000550000550fffb3bfffffb33fffffb33ffffffffff
0077770000ffffff00777777777700ff4434444444444344444444444443444405060060060060500506666006666050fffb38fffffb3bfffffb33ffffffffff
0077770000ffffff00777777777700ff4334444444443344444444344433444405066660066660500506006006006050fff338fffff338fffff333ffffffffff
007777777700000077777777777700ff4344433444433444444443344334444405500005500005500506006006006050fffb38fffffb38fffffb38ffffffffff
007777777700000077777777777700ff4444434444344444444433444444444400000000000000000506666006666050fff333fffff338fffff338ffffffffff
007777777777777777777777777777004bb44b4444b44bb444b433b4433b4b44ffffffffffffffff0550000550000550fffb33fffffb33fffffb38ffffffffff
0077777777777777777777777777770033333333333333333333433333433333ffffffffffffffff0000000000000000fff833fffffb3bfffff333ffffffffff
ff007777777777777777777777777700ffffffff00000000ffffffffffffffff00000000fffffffffffffffffffffffffff833fffff83bfffff333ffffffffff
ff007777777777777777777777777700ffffffffb3bbb3bb2222e222222e2222bbbbbbbbfffffffffffff6666ffffffffff833fffff83bfffff833ffffffffff
00777777777777777777777777777700ffffffff3333333322222e222222e22233333333ffffffffffff677766666666fff333fffff833fffff83bffffffffff
00777777777777777777777777777700ffffffff00000000ffff22e222222e2200000000ffffffffff66767666777676fff33bfffff333fffff833ffffffffff
00777777777777777777777777777700fffffffff08880fffffff22e22f222e2fff08880ffffffffff67776677767766fff333fffff333fffff33bffffffffff
00777777777777777777777777777700fffffffff08080ffffffff22efff222ffff08080ffffffff0000006777677766ff437b4fff43334fff43334fffffffff
ff007777777777777777777777777700ff000ffff0e880fffffffffffffffffffff0e880ffff000f0000000666666660f4938349f4938b49f4933349ffffffff
ff007777777777777777777777777700f033b0fff00000fffffffffffffffffffff00000fff0bbb00555555555555550ff44944fff44944fff44944fffffffff
ffff00777777777777777777777700fff0333b0000000000000000000000000000000000000bbbb00550000550000550fffffafffffffcffffffffffffffffff
ffff00777777777777777777777700ffff0333b3b3bbb3bbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbb0f0506666006666050fffffdfffffffdffffffffffffffffff
ffffff0000777777777777770000fffffff0333333333333333333333333333333333333333330ff0506006006006050fffffdffffdd2222ffffffffffffffff
ffffff0000007777777777770000ffffffff00000000000000000000000000000000000000000fff0506006006006050ff662222ffd88882ffffffffffffffff
ffffffffff00990000000000fffffffffffffffff088e0fffffffffffffffffffff088e0ffffffff0506666006666050ff688882ff2c8c82ffffffffffffffff
ffffffffff00990000000000fffffffffffffffff08080fffffffffffffffffffff08080ffffffff0550000550000550ff2a8a82ff288882ffffffffffffffff
ffffffffff00999999009900fffffffffffffffff08880fffffffffffffffffffff08880ffffffff0000000000000000ff288882ff222222ffffffffffffffff
ffffffffff00999999009900fffffffffffffffff00000fffffffffffffffffffff00000ffffffffffffffffffffffffff222222ffffffffffffffffffffffff
ffffffffffffffff00000000ffffffffffffffffffffffff00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffff0000000000ffffffffffffffffffffff0000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffff008888880000ffffffffffffffffffff008888880000ffffffffffffffffffff00000000ffffffffffffffffffffffff00000000ffffffff
ffffffffffffffff008888888800ffffffffffffffffffff008888888800ffffffffffffffffffff0000000000ffffffffffffffffffffff0000000000ffffff
ffffffffffffff000000008888880000ffffffffffffff000000008888880000ffffffffffffffff008888880000ffffffffffffffffffff008888880000ffff
ffffffffffffff022222e2222222e220fffffff00fffff022222e2222222e220ffffffffffffffff008888888800ffffffffffffffffffff008888888800ffff
ffffffffffffff0222222e2222222e20ffffff0000ffff0222222e2222222e20ffffffffffffff000f0000888888000fffffffffffffff000f0000888888000f
ffffffffffffff00007722e2222222e0fffff000700fff00007722e2222222e0ffffffffffffff022222e2222222e220ffffffffffffff022222e2222222e220
ff0000ffffffffff0077722e2299990fff0000077700ffff0077722e2299990fff0000ffffffff0222222e2222222e20ff0000ffffffff0222222e2222222e20
ff0000ffffffffff00777722e799990fff00000777700fff00777722e799990fff0000ffffffff00007722e2222222e0ff0000ffffffff00007722e2222222e0
0077770000ffffff00777777777700ff00770077777700ff00777777777700ff0077770000ffffff0077722e2299990f0077770000ffffff0077722e2299990f
0077770000ffffff00777777777700ff007700777777700f00777777777700ff0077770000ffffff00777722e799990f0077770000ffffff00777722e799990f
007777777700000000777777777700ff007700777777700000777777777700ff007777777700000000777777777700ff007777777700000000777777777700ff
007777000000000000777777777700ff007700777777770000777777777700ff007777777700000000777777777700ff007777777700000000777777777700ff
00777700700000777777777777777700007770077777777077777777777777000077777777777777777777777777770000777777777777777777777777777700
00777700770000007777777777777700007770077777777777777777777777000077777777777777777777777777770000777777777777777777777777777700
ff007700777700000077777777777700ff007007777777777007777777777700ff007777777777777777777777777700ff007777777777777777777777777700
ff007700777777770077777777777700ff007700777777777777777777777700ff007777777777777777777777777700ff007777777777777777777777777700
0077777007777777777777777777770000777770077777777777777777777700f0077777777777777777777777777700f0077777777777777777777777777700
0077777000077777777777777777770000777777007777777777777777777700f0077777777777777777777777777700f0007777777777777777777777777700
0077777700007777777777777777770000777777700777777777777777777700ff007777777777777777777777777700ff000077777777777777777777770000
0077777777000777777777777777770000777777770007777777777777777700ff007777777777777777777777777700ffff00777777777777777777777700ff
ff007777777777777777777777777700ff007777777777777777777777777700ffff00777777777777777777777700ffffffff0000777777777777770000ffff
ff007777777777777777777777777700ff007777777777777777777777777700ffff00777777777777777777777700ffffffff0000007777777777770000ffff
ffff00777777777777777777777700ffffff00777777777777777777777700ffffffff0000777777777777770000ffffffffffffff000000000000000fffffff
ffff00777777777777777777777700ffffff00777777777777777777777700ffffffff0000007777777777770000fffffff000fff0000000000000000f000fff
ffffff0000777777777777770000ffffffffff0000777777777777770000fffffffffffffff00000000000000ffffffffff09900009900ffff00990000990fff
ffffff0000007777777777770000ffffffffff0000007777777777770000fffffffffffffff00000000000000ffffffffff0990009990ffffff0999000990fff
ffffffffff00990000000000ffffffffffffffffff00990000000000ffffffffffffffff00009900ff00990000ffffffffff009999900fffffff09999900ffff
ffffffffff00990000000000ffffffffffffffffff00990000000000ffffffffffffffff00009900ff00990000ffffffffff00999900ffffffff00999900ffff
ffffffffff00999999009900ffffffffffffffffff00999999009900ffffffffffffffff00999900ff00999900ffffffffffff009900ffffffff009900ffffff
ffffffffff00999999009900ffffffffffffffffff00999999009900ffffffffffffffff00999900ff00999900ffffffffffff009900ffffffff009900ffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffeafffffff2ffffffffffffff2cfffffff2222eeeeee222222ffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbfffffffffff
ffffffeea9ffffff22ffffffffffff22ddffffff222e222222e22222ffffffffffffffffffffffffffffffffffffffffffffffbb3fffffbbb333bbffffffffff
fffffeee999fffff222ffffffffff22ecddfffff22e22222222e2222fffffffffffffffffffffffffffffffffffffffffffffbb33bbffbb3333333bb3fffffff
ffffeee29a99ffff2222ffffffff22eedcddffff2e2222222222e222fffffffffffffffffffffffffffffbb3ffffffffffffbb33333b33333333333bb33fffff
fffeee2299a99fff22222ffffff22eeeddcddfffe222222222222e22ffffffffffffffffffffbbfffffffb33fffffffffffbb333333bb33b33333333bb33ffff
ffeee222999a99ff222222ffff22eeeedddcddffe22eee22eee22e22ffffffffffffffffffbb33bbbbbff33ffbbfffffffbb3333bbb33333b333ff333bb33fff
feee2222a999999f2222222ff22eeeeedddddddfe2e88e22e88e2e22fffffffffffffffffb333333333b3b3bbb3b33ffffb3333bb33b3333bb33ffff333b3fff
eee22222aaaaaaaa2222222222eeeeee22222222e2e28e22e28e2e22fffffffffffffffff3fffffbbb33b3b3333333ffffb3333b333b33333bbb3fffff3b33ff
fffffffa22222222ee222222efffefffeeeeeeeee22ee2222ee22e22fffffffffffffffffffbbbb333bb333bfffffffffbb333fb334b333ff33b333ffffb33ff
ffffffaa22222222e2222222fefffeffeeeeeeee2e2222ee2222e222ffffffffffffffffffb33333fb333333b3fffffffb333fbb334bb344ff3bb33ffffb33ff
fffffaaa2222222222222222ffefffefeeeeeeee22ee22ee22ee2222fffffffffffffffffb333fffb33344333b3ffffffb333fb33f4bb334fff3bbb3fffbb3ff
ffffaaa92222222222222222fffefffeeeeeeeee222e222222e22222ffffffffffffffffff33fffb33f444ff33b3fffffb33ffb33f55b33555fff3b33fffbfff
fffaaa992222222222222222efffefffeeeeeeee222e2e22e2e22222ffffffffffffffffffffffb333f444ffff3b3ffffbb3ffbb3ff4b33344ffffbb3fffffff
ffaaa9992222222222222222fefffeffeeeeeeee222eeeeeeee22222ffffffffffffffffffffffb33ff555ffff3b3fffffb3fffbbff4b33344ffffbbffffffff
faaaaaaa2222222222222222ffefffefeeeeeeee2222222222222222ffffffffffffffffffffffb3fff444fffffb33ffffb3ffffbfffbb33444ffbbfffffffff
aaaaaaaa2222222222222222fffefffeeeeeeeee2222222222222222fffffffffffffffffffffb33fff444fffffb33ffffb3fffffffffbb4444fffffffffffff
fffffffcee22222ee2222222efffffff2eeeeeeeeee22222eeeeeeeefffffffffffffffffffffb33ff5555ffffff3fffffb3fffffffff555555fffffffffffff
ffffffcce22222ee22222222eeffffffeeeeeeeeee222ee2222eeeeeffffffffffffffffffffffffff4444ffffffffffffb3fffffffff444444fffffffffffff
fffffccd22222ee222222222eeefffffeeeeeeeee22eeeeeee22eee2ffffffffffffffffffffffffff4444fffffffffffff3fffffffff444444fffffffffffff
ffffccdd2222ee2222222222eeeeffffeeeeeeee22ee22222ee22ee2ffffffffffffffffffffffffff555fffffffffffffffffffffffff444444ffffffffffff
fffccddd222ee22222222222eeeeefffeeeeeeee2ee2ee2ee2ee2222fffffffffffffffffffff3bbff444fffffffffffffffffffffffff555554ffffffffffff
ffccdddd22ee222222222222eeeeeeffeeeeeeeeee2ee222ee2eeeeeffffffffffffffffbbb3fb33ff444fffffffffffffffffffffffff444455ffffffffffff
fccccccd2ee2222222222222eeeeeeefeeeeeeeee2ee22222ee22222ffffffffffffffff33333333bf444fffffffffffffffffffffffff444444ffffffffffff
22222222ee22222222222222eeeeeeeeeeeeeeeee22ee222ee222eeeffffffffffffffffffb3553bb3555fffffffffffffffffffffffff444444ffffffffffff
ffffffffffffffffffffffffffffffffffffffffee22ee2e222eeeeefffffffffffffffffbb344f333444ffffffffffffffffffffffff5555444ffffffffffff
ffffffffffffffffffffffffffffffffffffffffee2222222eeee222ffffffffffffffffbb3344ffff444ffffffffffffffffffffffff4445555ffffffffffff
ffffffffffffffffffffffffffffffffffffffffee22ee2eeeeee2e2ffffffffffffffff333f555ff5555fffffffffffffffffffffff44444444ffffffffffff
ffffffffbbbbbfffffffffffffffffffffffffffee22eee22eeeee22fffffffffffffffffffff44ff4444ffffffffffffffffffffff55554444fffffffffffff
eef9ffffffffffffffffff9fffffffffffffffffeee2eeee222eee2efffffffffffffffffffff44ff444444ffffffffffffffffffff44455555fffffffffffff
fffffffdddffffaaf2222ffffffffbbfffffffffeee2eeeeee22222efffffffffffffffffffff55f5555555fffffffffffffffffff44444444ffffffffffffff
ffffffffffffffffffffffffccffffffffffffffeeeeeeeeeeeeeeeefffffffffffffffffffffffffffffffffffffffffffffffff55555555fffffffffffffff
ffffffffffffffffffffffffffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
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

__map__
000001020300000000000000000000000000000000000000d3d3d3d3d3d3d3d3f0f1f2f30000000000000000000000e0c40000000000000000000000000000000000000000000000d0c1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001011121300000000000000000000000000000000000000d3d3d3d3d3d3d3d30000000000000000000000000000c3e4d4e3000000000000000000000000000000000000000000c0e1e2c20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002021212300000000000000000000000000000000000000d3d3d3d3d3d3d3d300000000000000000000000000c3e4e5e6d4e300000000000000000000000000000000000000c0e1e2d1d1c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
243031323329000000000000000000000000000000000000d3d3d3d3d3d3d3d3000000000000000000000000c3e4d4f5f6d4d4e30000000000000000000000000000000000c0d2d1c5c6d1d1c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
343536373839000000000000000000000000000000000000d3d3d3d3d3d3d3d30000000000000000000000c3e4d4d4d4d4d4d4d4e3000000000000000000000000000000c0d2d1d1d5d6d1d1d1c20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000d3d3d3d3d3d3d3d300000000000000000000c3e4d4d4d4d4d4d4d4d4d4e300000000000000000000000000c0e1d1d1d1d1d1d1d1d1d1c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000d3d3d3d3d3d3d3d3000000000000000000c3e4d4d4d4d4d4d4d4d4d4d4d4e30000000000000000000000c0e1e2d1d1d1d1d1d1d1d1d1d1c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000d3d3d3d3d3d3d3d30000000000000000c3e4d4d4d4d4d4d4d4d4d4d4d4d4d4e3000000000000000000c0e1e2d1d1d1d1d1d1d1d1d1d1d1d1c20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0d2d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0d2d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0d2d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1c20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0d2d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0d2d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0d2d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1c20000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0d2d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1c200000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0d2d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1c2000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000700001905124011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e00001d156241562a15627146231361d13618126121560c1560715605156031560000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600000
000e0000070700f0700e07015070090600f0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0000337502e750337502d750337502d750337502d750007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
__music__
00 00424344
00 40414344

