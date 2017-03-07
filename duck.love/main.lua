function love.load()
	last_button = "none"
	local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]

	math.randomseed( os.time() )

	duck_layouts = {}
	duck_layouts[0] = {1,1,1,1,1,1,1,1,1,1,1,1,1}

	love.graphics.setDefaultFilter("nearest", "nearest", 0)

	ui_font = love.graphics.newFont("assets/uni0553.ttf", 24)
	map_font = love.graphics.newFont("assets/uni0553.ttf", 14)
    love.graphics.setFont(ui_font)

    duck = love.graphics.newImage("assets/duck.png")
    jump = love.graphics.newImage("assets/jump.png")
    splash = love.graphics.newImage("assets/splash.png")

    splash_sound = love.audio.newSource("assets/splash_lo.wav", "static")
    jump_sound = love.audio.newSource("assets/jump_lo.wav", "static")

    reset_level()
end

function reset_level()
	map = {}
	npcs = {}
	effects = {}

    map_w = 13
    map_h = 18
    map_x_offset = 0
    map_y_offset = 40
    tile_w = 60
    tile_h = 40
    current_level = 1

    speed = 1
    player_speed = 1.5

    -- build out map
    print("Building map...")

    for y=1, map_h do
        map[y] = {}
       for x=1, map_w do
          map[y][x] = 0
       end
    end

    for y=1, 3 do
       for x=1, map_w do
          map[y][x] = 1
       end
    end

    for y=14, map_h do
       for x=1, map_w do
          map[y][x] = 1
       end
    end

    print("Map is " .. map_w .. " wide by " .. map_h .. " tall")

    print("Map built.")
	set_up_level(current_level)

    player = {location = {x = 0, y = 600}, rotation = 0, scale = 4, altitude = 1, status = "alive", opacity = 1, is_colliding = false, jump=false}
end

function love.update(dt)

	
	check_collisions(dt)
	update_ducks()

	if player.status ~= "dead" then
		if love.keyboard.isDown("right") then
	        player.location.x = player.location.x + (1*player_speed)
	        return;
	    end

	    if love.keyboard.isDown("left") then
	        player.location.x = player.location.x - (1*player_speed)
	        return;
	    end

		if love.keyboard.isDown("up") then
	        player.location.y = player.location.y - (1*player_speed)
	        return;
	    end

	    if love.keyboard.isDown("down") then
	        player.location.y = player.location.y + (1*player_speed)
	        return;
	    end
	end
end

function set_up_level(current_level)
	--map[1] = duck_layouts[0]
	add_ducks(current_level)
end

function add_ducks(current_level)
	for x=1, map_w do
		for y=1, map_h-8 do
			screen_x, screen_y = calculate_screen_position_from_map_coordinates(x,y)
			if (math.random(0,1) == 1) then
				npcs[#npcs+1] = {type = "duck", name = "duck", opacity = 1, location = {x = screen_x, y = screen_y+(tile_h*3)}}
			end
		end
	end
end

function love.draw()
	draw_map()
	draw_effects()
	draw_ducks()
	draw_jump()
end

function calculate_map_position_from_screen_coordinates(x,y)
	map_tile_x = math.ceil((x)/tile_w) - ((map_x_offset/tile_w))
	map_tile_y = math.ceil((y)/tile_h) - ((map_y_offset/tile_h))

	map_y = ((map_tile_y*tile_h))
    map_x = ((map_tile_x*tile_w)) - (tile_w)

	return map_x, map_y
end

function calculate_screen_position_from_map_coordinates(x,y)
	map_y = ((y*tile_h)+map_y_offset)-tile_h
    map_x = ((x*tile_w)+map_x_offset)-tile_w

    return map_x, map_y
end

function collides_with(x1,y1,w1,h1, x2,y2,w2,h2)

	return x1 < x2+(w2-25) and
		x2 < x1+(w1-25) and
		y1 < y2+(h2-15) and
		y2 < y1+(h1-15)
end

function draw_map()
	love.graphics.setColor(255, 255, 255, 255)
    for y=1, map_h do
        for x=1, map_w do

        	screen_x, screen_y = calculate_screen_position_from_map_coordinates(x,y)

	        if map[y][x] == 0 then
	            -- water
	            love.graphics.setColor(0, 128, 255)
	            love.graphics.rectangle( 'fill', screen_x, screen_y,  tile_w, tile_h)
	        elseif map[y][x] == 1 then
	            -- grass
	            love.graphics.setColor(19, 135, 9)
	            love.graphics.rectangle( 'fill', screen_x, screen_y,  tile_w, tile_h)
	        elseif map[y][x] == 2 then
	            -- dirt
	            love.graphics.setColor(133, 94, 33)
	            love.graphics.rectangle( 'fill', screen_x, screen_y,  tile_w, tile_h)
	        end

	        love.graphics.setFont(map_font)
			love.graphics.setColor(255,255,255)
	        --love.graphics.print(x..","..y,current_x_pos,current_y_pos)
        	love.graphics.setFont(ui_font)
        end

    end

end

function draw_ducks()
	love.graphics.setColor(255, 255, 255, 255)

	for i=1, #npcs do
		if npcs[i].type == "duck" then
			--screen_x, screen_y = calculate_screen_position_from_map_coordinates(npcs[i].location.x,npcs[i].location.y)

			love.graphics.draw( duck, npcs[i].location.x, npcs[i].location.y, npcs[i].location.opacity, 4, 4)

			--love.graphics.print(npcs[i].location.y,npcs[i].location.x, npcs[i].location.y)
		end
	end
end

function draw_jump()
	if player.jump ~= false then
		player_speed = 3

		if player.jump == "up" then
			player.altitude = player.altitude + .05
		end

		if player.altitude >= 1.5 then
			player.jump = "down"
		end

		if player.jump == "down" then
			player.altitude = player.altitude - .05
		end

		if player.altitude < 1 then 
			player.altitude = 1
			player.jump = false
		end
	end

	if player.status ~= "dead" then
		love.graphics.draw(jump, player.location.x, player.location.y, player.rotation , player.scale*player.altitude, player.scale*player.altitude)
	end
end

function create_splash(x,y)
	effects[#effects+1] = {location={x=x,y=y}}
end

function draw_effects()
	for i=1, #effects do
		love.graphics.draw(splash, effects[i].location.x, effects[i].location.y, 0 , 4, 4)
	end
end

function check_collisions()

	collided = false

	if player.location.y+20 >= (14 * tile_h) or player.location.y <= 3 * tile_h then
		
	else
		for i=1, #npcs do
			if npcs[i].type == "duck" then

				if collides_with(player.location.x, player.location.y, 60, 40, npcs[i].location.x, npcs[i].location.y, 60, 40) then
					player.location.x = player.location.x + speed
					collided = true
					return;
				else
					
				end
			end
		end

		if collided == false and player.jump == false and player.status ~= "dead" then
			splash_sound:play()
			create_splash(player.location.x, player.location.y)
			player.status = "dead"
		end
	end

	if player.location.x == 2 then

	end
end

function update_ducks(dt)
	for i=1, #npcs do
		if npcs[i].type == "duck" then

			npcs[i].location.x = npcs[i].location.x + (1*speed)

			if(npcs[i].location.x == 720) then
				npcs[i].location.x = 0
			end

			love.graphics.draw( duck, npcs[i].location.x, npcs[i].location.y, 0, 4, 4)
		end

		if npcs[i].type == "smartduck" then

			print(npcs[i].location.y)
			if(npcs[i].location.y == tile_h*2) then
				npcs[i].location.x = npcs[i].location.x + (1*speed)
			end

			if(npcs[i].location.x == 720) then
				npcs[i].location.y = npcs[i].location.y + (1*speed)
			end

			if(npcs[i].location.y == (tile_h*map_h)-40) then
				npcs[i].location.x = npcs[i].location.x - (1*speed)
			end

			if(npcs[i].location.x == 0) then
				npcs[i].location.y = npcs[i].location.y - (1*speed)
			end

			love.graphics.draw( duck, npcs[i].location.x, npcs[i].location.y, 0, 4, 4)
		end
	end
end

function love.keypressed(key)
   if key == "space" then
      player_jump()
   end

   if key == "r" then
   		reset_level()
   end
end

function player_jump()
	player.jump = "up"
    jump_sound:play()
end

function love.gamepadpressed( joystick, button )

	last_button = button
	print(button)
	if button == "a" then
		player_jump()
	end

end
