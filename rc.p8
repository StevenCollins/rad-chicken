pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- rad chicken
-- rubber chicken studios

-- constants.
cartdata("rad_chicken")
bg_colour=1
trans_colour=15

function _init() title_init() end

function title_init()
	_update60=title_update
	_draw=title_draw
	
	-- create pause menu item.
	menuitem(1, "reset highscore",
			function()
				dset(0,0)
				highscore=0
			end
	)
	
	-- set transparency.
	palt(0,false)
	palt(trans_colour,true)
end

function title_update()
	if (btn()>0) then -- start game.
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
	local offset=80
	print("rad chicken",42,offset,7)
	offset+=8
	print("🅾️/z to jump",40,offset,7)
	offset+=8
	print("⬆️ or ⬇️ for tricks",26,offset,7)
	offset+=8
	print("any button to start",26,offset,7)
end

function game_init()
	_update60=game_update
	_draw=game_draw
	
	-- game state.
	cntr=0 -- just a counter that increases every frame.
	game_over=false
	score=0
	highscore=dget(0) -- get highscore from cart data
	
	-- init all the things!
	make_chicken()
	make_ground()
	make_obstacles()
end

function game_update()
	cntr+=1 -- increase the counter.
	if (not game_over) then
	 move_ground()
	 move_chicken()
	 move_obstacles()
	elseif (btn(❎)) then -- reset game.
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
	
	-- print(stat(1)) -- cpu usage
end

-- 0 to 7 counter
function step()
	return cntr%8
end
-->8
-- chicken
-- init constants.
g_level=81
gravity=0.2
jump_power=0.5
jump_length=10 -- number of frames the jump button works for.
tt_length=30 -- number of frames trick text appears for.
tt_pre={"rad","awe","tube","cowab"}
tt_suf={"ical","some","ular","unga"}

c_sprites={ -- default sprite.
		{ 0, 0, 1, 2, 3, 0},
		{ 0,16,17,18,19, 0},
		{ 0,32,33,34,35, 0},
		{20,48,49,50,51,25},
		{36,37,38,39,40,41}}
c_1_sprites={ -- redbull frames.
		{{ 0,  0, 65, 66, 67, 0},
		 { 0, 80, 81, 82, 83, 0},
		 { 0, 96, 97, 98, 99, 0},
		 {20,112,113,114,115,25},
		 {36, 37, 38, 39, 40,41}},
		{{ 0, 68, 69, 70, 71, 0},
		 { 0, 84, 85, 86, 87, 0},
		 { 0,100,101,102,103, 0},
		 {20,116,117,118,119,25},
		 {36, 37, 38, 39, 40,41}},
 	{{ 0,  0, 65, 66, 67, 0},
		 { 0, 80, 81, 82, 83, 0},
		 { 0, 96, 97, 98, 99, 0},
		 {20,112,113,114,115,25},
		 {36, 37, 38, 39, 40,41}},
	{{ 0, 0, 1, 2, 3, 0},
		{ 0,16,17,18,19, 0},
		{ 0,32,33,34,35, 0},
		{20,48,49,50,51,25},
		{36,37,38,39,40,41}},
	 {{ 0, 68, 69, 70, 71, 0},
		 { 0, 84, 85, 86, 87, 0},
		 { 0,100,101,102,103, 0},
		 {20,116,117,118,119,25},
		 {36, 37, 38, 39, 40,41}},
	 {{ 0,  0, 65, 66, 67, 0},
		 { 0, 80, 81, 82, 83, 0},
		 { 0, 96, 97, 98, 99, 0},
		 {20,112,113,114,115,25},
		 {36, 37, 38, 39, 40,41}}}
c_1_sprites_list={1,1,1,1,2,2,2,2,3,3,3,3,2,2,2,2} -- redbull frame order.
c_2_sprites={ -- jackson frames.
		{{ 0,  0,129,130,131, 0},
		 { 0,144,145,146,147, 0},
		 { 0,160,161,162,163, 0},
		 {20,176,177,178,179,25},
		 {36, 37, 38, 39, 40,41}},
		{{ 0,  0,133,134,135, 0},
		 { 0,148,149,150,151, 0},
		 { 0,164,165,166,167, 0},
		 {20,180,181,182,183,25},
		 {36, 37, 38, 39, 40,41}}}
c_2_sprites_list={1,1,1,1,2,2,2,2} -- jackson frame order.
l_w_sprites={21,37} -- left wheel sprites.
r_w_sprites={24,40} -- right wheel sprites.

function make_chicken()
	c={}
	c.x=2
	c.y=g_level
	c.dx=0
	c.dy=0
	c.bump_offset=0
	c.jump_frame=0
	c.spriteset=c_sprites
	c.trickd=false
	c.tt=""
	c.tt_cntr=0
end

function move_chicken()
	-- landed a trick.
	if (c.y==g_level and c.trickd and c.tt_cntr==0) then
		c.trickd=false
		c.tt=rnd(tt_pre)..rnd(tt_suf)
		score+=10
	end
	-- trick text maintenance.
	if (c.tt!="" and c.tt_cntr<=tt_length) then
		c.tt_cntr+=1
	elseif (c.tt_cntr>=tt_length) then
		c.tt=""
		c.tt_cntr=0
	end
	
	-- tricks.
	if (btn(⬆️)) then -- redbull.
		c.spriteset=c_1_sprites[c_1_sprites_list[(cntr%#c_1_sprites_list)+1]]
		c.dy+=gravity/2
		c.trickd=true
	elseif (btn(⬇️)) then -- jackson.
		c.spriteset=c_2_sprites[c_2_sprites_list[(cntr%#c_2_sprites_list)+1]]
		c.dy+=gravity*2
		c.trickd=true
	else -- no tricks.
		c.spriteset=c_sprites
		c.dy+=gravity
	end
	
	-- do jump.
	if ((
				-- check on the ground,
				btn(🅾️) and
				c.y==g_level and
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
	if (c.y>g_level) then
		c.y=g_level
		c.dy=0
	end
end

function draw_chicken()
	-- bumpy! set 0 or 1px y offset every 4 frames.
	if (c.y==g_level) then -- on the ground?
		if (cntr%4==0) do
			c.bump_offset=flr(rnd(2))
		end
	else
		c.bump_offset=0 -- no offset in the air.
	end
	-- do wheel animation every 4 frames.
	if (cntr%4==0) then
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
-- ground and overlay
-- init constants.
g_sprites={4,5,6,7}

function make_ground()
	g={}
	g.sprites={}

	-- for the width of the screen plus 1 sprites,
	-- select a random ground sprite.
	for i=1,17 do
		g.sprites[i]=rnd(g_sprites)
	end
end

function move_ground()
	-- if we just hit the 8px boundary...
	if (step()==0) then
		-- add new sprite,
		add(g.sprites,rnd(g_sprites))
		-- remove first sprite,
		del(g.sprites,g.sprites[1])
		-- and increase the score!
		score+=1
	end
end

function draw_ground()
	for i, sprite in ipairs(g.sprites) do
		spr(sprite,i*8-8-step(),120)
	end
end

function draw_overlay()
	if (not game_over) then
		print(highscore,7)
		print(score,7)
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
	{{{8}},{{26}}},
	{{{9,10}},{{57,58}}},
	{{{11},
	  {27},
	  {43}},
	 {{12},
	  {28},
	  {44}},
	 {{13},
	  {29},
	  {45}}},
	{{{14,15},
	  {30,31}},
	 {{46,47},
	  {62,63}},
	 {{78,79},
	  {94,95}}}}
o_sprites_list={ -- table{obstacle{frame}}.
	{1,1,1,1,2,2,2,2},
	{1,1,1,1,2,2,2,2},
	{1,1,1,1,2,2,2,2,3,3,3,3,2,2,2,2},
	{1,1,1,1,2,2,2,2,3,3,3,3,2,2,2,2}}
o_g_obstacles={1,2,3} -- ground obstacles.
o_f_obstacles={4} -- flying obstacles.
o_f_chance=0.2 -- chance for obstacle to be flying.
o_overhang=2 -- leftside buffer so onscreen obstacles don't disappear.
o_offset=3 -- push obstacles slightly into ground.
o_cntdn_min=12 -- minimum spritewidths until next obstacle.
o_cntdn_max=20 -- maximum ...
o_height_min=2 -- minimum obstacle height (rows from top).
o_height_max=13 -- maximum ...
o_height_ground=15

function make_obstacles()
 -- bit of a misnomer, obstacles are made in move.
 -- this initializes the obstacle tables.
 o={}
 for y=1,16 do
 	o[y]={}
		for x=1,17+o_overhang do -- 17 so obstacles spawn offscreen.
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
			o_cntdn=flr(rnd(o_cntdn_max-o_cntdn_min))+o_cntdn_min -- reset the countdown.
			-- choose a new obstacle.
			if (rnd()<o_f_chance) then -- flying obstacle.
				new_obstacle=rnd(o_f_obstacles)
				new_obstacle_y=flr(rnd(o_height_max))+o_height_min
			else -- ground obstacle.
				new_obstacle=rnd(o_g_obstacles)
				new_obstacle_y=o_height_ground
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
				ost=o_sprites[obstacle][o_sprites_list[obstacle][flr(cntr%#o_sprites_list[obstacle])+1]]
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
					if (pget(x+pxl_x,y+pxl_y)!=bg_colour) then -- is the pixel we're checking not the bg colour?
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
	if (score>highscore) then
		dset(0,score)
	end
end
__gfx__
ffffffffffffffff00000000fffffffffbbffbffffbffbbfffbf33bff33bfbffffffafffcddfff0f0fffcddffbb33fffffffffffffffffffffffffffffff6666
ffffffffffffffff0000000000ffffff33333333333333333333433333433333ffffdfffffdfffe022ffffdfffbf378ffbb33fffffffffffffffff666f666776
ffffffffffffffff008888880000ffff44344444444443444444444444434444ffffdfffcddffea9a92fcddfff3f3fbfff3f388ffbb3333fffff666766667676
ffffffffffffffff008888888800ffff43344444444433444444443444334444fee2222fffdffe99992fffdfbfbf3f3fffbf3fbffbb33b3ffff6677766677776
ffffffffffffffffff000088888800ff43444334444334444444433443344444fe88882fffdfe22222222fdfbf3833bfbf33333ffb3333bfff66767666776766
fffffffffffffff22222e2222222e22f44444344443444444444334444444444f2a8a82fffdde22222222ddffbb733bffbb833bffbb3333fff6777667776776f
fffffffffffffff222222e2222222e2f4bb44b4444b44bb444b433b4433b4b44f288882fffff222255555fffff3833ffff373bffff3833ff0000006777777660
ffffffffffffffff007722e2222222ef33333333333333333333433333433333f222222fffff555555555ffffff333fffff83bfffff733ff0000000666666600
ff0000ffffffffff0077722e22999900ffffffff00000000ffffffffffffffff00000000ffffffffffffcffffffb33fffffb33fffff833ff0555555555555550
ff0000ffffffffff00777722e7999900ffffffffb3bbb3bbffffffffffffffffbbbbbbbbffffffffffffdffffffb3bfffffb33fffffb33ff0550000550000550
0077770000ffffff00777777777700ffffffffff33333333ffffffffffffffff33333333ffffffffffffdffffffb38fffffb3bfffffb33ff0506666006666050
0077770000ffffff00777777777700ffffffffff00000000ffffffffffffffff00000000fffffffffee2222ffff338fffff338fffff333ff0506006006006050
007777777700000077777777777700fffffffffff08880fffffffffffffffffffff08880fffffffffe88882ffffb38fffffb38fffffb38ff0506006006006050
007777777700000077777777777700fffffffffff08080fffffffffffffffffffff08080fffffffff2c8c82ffff333fffff338fffff338ff0506666006666050
00777777777777777777777777777700ff000ffff0e880fffffffffffffffffffff0e880ffff000ff288882ffffb33fffffb33fffffb38ff0550000550000550
00777777777777777777777777777700f033b0fff00000fffffffffffffffffffff00000fff0bbb0f222222ffff833fffffb3bfffff333ff0000000000000000
ff007777777777777777777777777700f0333b0000000000000000000000000000000000000bbbb0fffffffffff833fffff83bfffff333ffffffffffffffffff
ff007777777777777777777777777700ff0333b3b3bbb3bbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbb0ffffffffffff833fffff83bfffff833fffffff6666fffffff
00777777777777777777777777777700fff0333333333333333333333333333333333333333330fffffffffffff333fffff833fffff83bffffff677766666666
00777777777777777777777777777700ffff00000000000000000000000000000000000000000ffffffffffffff33bfffff333fffff833ffff66767666777676
00777777777777777777777777777700fffffffff088e0fffffffffffffffffffff088e0fffffffffffffffffff333fffff333fffff33bffff67776677767766
00777777777777777777777777777700fffffffff08080fffffffffffffffffffff08080ffffffffffffffffff437b4fff43334fff43334f0000006777677766
ff007777777777777777777777777700fffffffff08880fffffffffffffffffffff08880fffffffffffffffff4938349f4938b49f49333490000000666666660
ff007777777777777777777777777700fffffffff00000fffffffffffffffffffff00000ffffffffffffffffff44944fff44944fff44944f0555555555555550
ffff00777777777777777777777700ffffffffffffffffffffffffffffffffffffffffffffffffafafffffffffffffffffffffffffffffff0550000550000550
ffff00777777777777777777777700ffffffffffffffffffffffffffffffffffffffffffaddfffea22fffaddffffffffffffffffffffffff0506666006666050
ffffff0000777777777777770000ffffffffffffffffffffffffffffffffffffffffffffffdffec1c12ffffdffffffffffffffffffffffff0506006006006050
ffffff0000007777777777770000ffffffffffffffffffffffffffffffffffffffffffffaddffe11112ffaddffffffffffffffffffffffff0506006006006050
ffffffffff00990000000000ffffffffffffffffffffffffffffffffffffffffffffffffffdfe22222222ffdffffffffffffffffffffffff0506666006666050
ffffffffff00990000000000ffffffffffffffffffffffffffffffffffffffffffffffffffdde22222222dddffffffffffffffffffffffff0550000550000550
ffffffffff00999999009900ffffffffffffffffffffffffffffffffffffffffffffffffffff222255555fffffffffffffffffffffffffff0000000000000000
ffffffffff00999999009900ffffffffffffffffffffffffffffffffffffffffffffffffffff555555555fffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffff00000000ffffffffffffffffffffffff00000000ffffffffffffffffffffffff00000000ffffffffffffffffffffffffffffffffffffffff
ffffffffffffffff0000000000ffffffffffffffffffffff0000000000ffffffff000ffffff00fff0000000000ffffffffffffffffffffffffff66666fffffff
ffffffffffffffff008888880000ffffffffffffffffffff008888880000ffffff0000fffff000ff008888880000ffffffffffffffffffffff66777666666666
ffffffffffffffff008888888800ffffffffffffffffffff008888888800ffffff0000fffff0000f008888888800ffffffffffffffffffffff67676677677676
ffffffffffffffffff000088888800ffffffffffffffffffff000088888800fffff0000fffff0700ff000088888800ffffffffffffffffff0000006776777766
fffffffffffffff222222e2222222e2ffffffff00ffffff2222222e2222222effff0000fffff077222222e2222222e2fffffffffffffffff0000000666666660
fffffffffffffff2222222e2222222efffffff0000fffff22222222e2222222ffff00700ffff0772222222e2222222efffffffffffffffff0555555555555550
ffffffffffffffff0077222e2222222ffffff000700fffff00772222e222222ffff00700ffff07770077222e2222222fffffffffffffffff0550000550000550
ff0000ffffffffff00777222e2999900ff0000077700ffff007772222e999900ff00077000fff07700777222e2999900ffffffffffffffff0506666006666050
ff0000ffffffffff0077772227999900ff00000777700fff0077772227999900ff000077000ff0770077772227999900ffffffffffffffff0506006006006050
0077770000ffffff00777777777700ff007700777777000000777777777700ff007700777000f07700777777777700ffffffffffffffffff0506006006006050
0077770000ffffff00777777777700ff007700777777700700777777777700ff007700077700007700777777777700ffffffffffffffffff0506666006666050
007777777700000077777777777700ff007700777777700077777777777700ff007770077770007007777777777700ffffffffffffffffff0550000550000550
007777000000000077777777777700ff007700777777770007777777777700ff007770077777000007777777777700ffffffffffffffffff0000000000000000
007777007000007777777777777777000077700777777770007777777777770000777007777770000077777777777700ffffffffffffffffffffffffffffffff
007777007700000007777777777777000077700777777777000777777777770000777000777777000007777777777700ffffffffffffffffffffffffffffffff
ff007700777700000077777777777700ff007007777777777007777777777700ff007700777777700007777777777700cddfff0f0fffcddfffffffffffffffff
ff007700777777770077777777777700ff007700777777777777777777777700ff007700777777777777777777777700ffdfffe022ffffdfffffffffffffffff
007777700777777777777777777777000077777007777777777777777777770000777700077777777777777777777700cddffea9a92fcddfffffffffffffffff
007777700007777777777777777777000077777700777777777777777777770000777770007777777777777777777700ffdffe99992fffdfffffffffffffffff
007777770000777777777777777777000077777770077777777777777777770000777770000077777777777777777700ffdfe22222222fdfffffffffffffffff
007777777700077777777777777777000077777777000777777777777777770000777777700000777777777777777700ffdde22222222ddfffffffffffffffff
ff007777777777777777777777777700ff007777777777777777777777777700ff007777777000777777777777777700ffff222255555fffffffffffffffffff
ff007777777777777777777777777700ff007777777777777777777777777700ff007777777777777777777777777700ffff555555555fffffffffffffffffff
ffff00777777777777777777777700ffffff00777777777777777777777700ffffff00777777777777777777777700ffffffafffffffcfffffffffffffffffff
ffff00777777777777777777777700ffffff00777777777777777777777700ffffff00777777777777777777777700ffffffdfffffffdfffffffffffffffffff
ffffff0000777777777777770000ffffffffff0000777777777777770000ffffffffff0000777777777777770000ffffffffdfffffffdfffffffffffffffffff
ffffff0000007777777777770000ffffffffff0000007777777777770000ffffffffff0000007777777777770000fffffee2222ffee2222fffffffffffffffff
ffffffffff00990000000000ffffffffffffffffff00990000000000ffffffffffffffffff00990000000000fffffffffe88882ffe88882fffffffffffffffff
ffffffffff00990000000000ffffffffffffffffff00990000000000ffffffffffffffffff00990000000000fffffffff2a8a82ff2c8c82fffffffffffffffff
ffffffffff00999999009900ffffffffffffffffff00999999009900ffffffffffffffffff00999999009900fffffffff288882ff288882fffffffffffffffff
ffffffffff00999999009900ffffffffffffffffff00999999009900ffffffffffffffffff00999999009900fffffffff222222ff222222fffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffff00000000ffffffffffffffffffffffff0000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffff0000000000ffffffffffffffffffffff0000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffff008888880000ffffffffffffffffffff008888880000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffff008888888800ffffffffffffffffffff008888888800ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffff000088888800ffffffffffffffffffff000088888800ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffff22222e2222222e22ffffffffffffffff22222e2222222e22fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff0000fffffffff222222e2222222e2fff0000fffffffff222222e2222222e2fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff0000ffffffffff007722e2222222efff0000ffffffffff007722e2222222efffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0077770000ffffff0077722e229999000077770000ffffff0077722e22999900ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0077770000ffffff00777722e79999000077770000ffffff00777722e7999900ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
007777777700000077777777777700ff007777777700000000777777777700ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
007777777700000077777777777700ff007777777700000000777777777700ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0077777777777777777777777777770000777777777777777777777777777700ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0077777777777777777777777777770000777777777777777777777777777700ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff007777777777777777777777777700ff007777777777777777777777777700ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff007777777777777777777777777700ff007777777777777777777777777700ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f0077777777777777777777777777700f0077777777777777777777777777700ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f0077777777777777777777777777700f0007777777777777777777777777700ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff007777777777777777777777777700ff000077777777777777777777770000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff007777777777777777777777777700ffff00777777777777777777777700ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffff00777777777777777777777700ffffffff0000777777777777770000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffff00777777777777777777777700ffffffff0000007777777777770000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffff0000777777777777770000ffffffffffffff000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffff0000007777777777770000fffffff000fff0000000000000000f000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffff00000000000000ffffffffff09900009900ffff00990000990fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffff00000000000000ffffffffff0990009990ffffff0999000990fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffff00009900ff00990000ffffffffff009999900fffffff09999900ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffff00009900ff00990000ffffffffff00999900ffffffff00999900ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffff00999900ff00999900ffffffffffff009900ffffffff009900ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffff00999900ff00999900ffffffffffff009900ffffffff009900ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0000000ee000000020000000000000022000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000ee220000002200000000000022ee000000000000000000eeeeeee0000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00000ee222200000222000000000022eeee00000000000000eeeeeeeeeeeee0000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0000ee222222000022220000000022eeeeee00000000000eeeee2222222eeeee00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000ee222222220002222200000022eeeeeeee000000000eee222eeeeeee222eee0000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00ee222222222200222222000022eeeeeeeeee0000000eee2eeeeeeeeeeeee2eee000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0ee222222222222022222220022eeeeeeeeeeee00000eee2eeeeeeeeeeeeeee2eee00000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ee222222222222222222222222eeeeeeeeeeeeee000eee2eeeeeeeeeeeeeeeee2eee0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0000000022222222e2222222e000e000eeeeeeee00eee2eeeeeeeeeeeeeeeeeee2eee000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0000000022222222222222220e000e00eeeeeeee00ee2eeeeeeeeeeeeeeeeeeeee2ee000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00000000222222222222222200e000e0eeeeeeee0ee2eeeeeeeeeeeeeeeeeeeeeee2ee00ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000002222222222222222000e000eeeeeeeee0ee2eeeeeeeeeeeeeeeeeeeeeee2ee00ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000002222222222222222e000e000eeeeeeee0ee2eeeeeeeeeeeeeeeeeeeeeee2ee00ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0000000022222222222222220e000e00eeeeeeeeee2eeeeeeeeeeeeeeeeeeeeeeeee2ee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00000000222222222222222200e000e0eeeeeeeeee2eeeeeeeeeeeeeeeeeeeeeeeee2ee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000002222222222222222000e000eeeeeeeeeee2eeeeeeeeeeeeeeeeeeeeeeeee2ee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffe00000002eeeeeeeee2eeeeeeeeeeeeeeeeeeeeeeeee2ee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffee000000eeeeeeeeee2eeeeeeeeeeeeeeeeeeeeeeeee2ee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffeee00000eeeeeeeeee2eeeeeeeeeeeeeeeeeeeeeeeee2ee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffeeee0000eeeeeeeeee2eeeeeeeeeeeeeeeeeeeeeeeee2ee0ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffeeeee000eeeeeeee0ee2eeeeeeeeeeeeeeeeeeeeeee2ee00ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffeeeeee00eeeeeeee0ee2eeeeeeeeeeeeeeeeeeeeeee2ee00ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffeeeeeee0eeeeeeee0ee2eeeeeeeeeeeeeeeeeeeeeee2ee00ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffeeeeeeeeeeeeeeee00ee2eeeeeeeeeeeeeeeeeeeee2ee000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffff00eee2eeeeeeeeeeeeeeeeeee2eee000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffff000eee2eeeeeeeeeeeeeeeee2eee0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffff0000eee2eeeeeeeeeeeeeee2eee00000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffff00000eee2eeeeeeeeeeeee2eee000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffff000000eee222eeeeeee222eee0000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffff0000000eeeee2222222eeeee00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffff000000000eeeeeeeeeeeee0000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffff000000000000eeeeeee0000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
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
0000010203000000d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d3d3d3d3d3d3d3d3d0d0d0d0d0d0d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010111213000000d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d3d3d3d3d3d3d3d3d0d0c5c6c7c8d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020212123000000d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d3d3d3d3d3d3d3d3d0d0d5d6d6d8d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1430313233190000d0d0d0c0c1d0d0d0d0d0d0d0d0d0d0d0d3d3d3d3d3d3d3d3d0d0e5d6d6e8d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2425262728290000d0d0c0d2d1c2d0d0d0d0d0c3c4d0d0d0d3d3d3d3d3d3d3d3d0d0f5f6f7f8d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d0c0d2d1d1d1c2d0d0d0c3e4d4e3d0d0d3d3d3d3d3d3d3d3d0d0d0d0d0d0d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000c0d2d1d1d1d1d1c2d0c3e4d4d4d4e3d0d3d3d3d3d3d3d3d3d0d0d0d0d0d0d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d3d3d3d3d3d3d3d3d0d0d0d0d0d0d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
