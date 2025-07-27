function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    math.randomseed(os.time())
    love.window.setMode(1080, 800)
    love.window.setTitle("Pong - AAOOII")

    ww, wh = love.window.getMode()

    font = love.graphics.newFont("Exo.ttf")
    love.graphics.setFont(font)

    dir = math.random(0, 2*math.pi)

    ball = {
        x = ww/2,
        y = wh/2 + 65,
        radius = 15,
        speed = {            
            x = math.sin(dir),
            y = math.cos(dir)
        }
    }

    player = {
        w = 20,
        h = 100,
        x = ww - 20 - 10,
        y = (wh/2)-50,
        speed = 5
    }

    bot = {
        w = 20,
        h = 100,
        x = 10,
        y = (wh/2)-50,
        speed = 5
    }

    botFocus = {
        x = ball.x,
        y = ball.y
    }

    points = {
        player = 0,
        bot = 0
    }

    winrate = 0

    time = 0

    rate = 100

    afk = false
end

function ball_reset()
    rate = 100
    ball.x = ww/2
    ball.y = wh/2
    ball.speed.x = math.sin(dir)
    ball.speed.y = math.cos(dir)
end

function love.update(dt)
    time = time + 1 * dt
    rate = rate + 10 * dt
    dir = math.random(0, 2*math.pi)

    ball.x = ball.x + ball.speed.x * rate * dt
    ball.y = ball.y + ball.speed.y * rate * dt

    winrate = points.player / (points.player + points.bot + 0.01)

    -- Check goal
    if ball.x + ball.radius >= ww + ball.radius*2 then
        ball_reset()
        points.bot = points.bot + 1
    end
    
    if ball.x - ball.radius <= 0 - ball.radius*2  then
        ball_reset()
        points.player = points.player + 1
    end

    -- check top and bottom
    if ball.y + ball.radius >= wh then
        ball.speed.y = -math.abs(ball.speed.y)
        ball.speed.x = math.sin(dir)
    end

    if ball.y - ball.radius <= 0  then
        ball.speed.y = math.abs(ball.speed.y)
        ball.speed.x = math.sin(dir)
    end

    -- Check paddles' collision
    if ball.x + ball.radius >= player.x and ball.y + ball.radius >= player.y and ball.y - ball.radius <= player.y + player.h then
        ball.speed.x = -math.abs(ball.speed.x)
    end

    if ball.x - ball.radius <= bot.x + bot.w and ball.y + ball.radius >= bot.y and ball.y - ball.radius <= bot.y + bot.h then
        ball.speed.x = math.abs(ball.speed.x)
    end

    -- Control player's paddle
    if not afk then
        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            player.y = player.y + player.speed
        elseif love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            player.y = player.y - player.speed
        end
    end

    if afk then
        if ball.x > ww/2 then
            if ball.y < player.y + player.h then
                player.y = player.y - player.speed
            end
        
            if ball.y > player.y + player.h then
                player.y = player.y + player.speed
            end
        end
    end

    -- Player's paddle limits
    if player.y < 10 then
        player.y = 10
    end

    if player.y + player.h > wh - 10 then
        player.y = wh - 10 - player.h
    end

    -- AI
    if math.random(1, 100) < 50 * winrate then
        botFocus = {
            x = ball.x,
            y = ball.y
        }
    end

    if botFocus.x < ww/2 then
        if botFocus.y < bot.y + bot.h then
            bot.y = bot.y - bot.speed
        end
    
        if botFocus.y > bot.y + bot.h then
            bot.y = bot.y + bot.speed
        end
    end

    if botFocus.x > ww/2 then -- sillyness
        if math.sin(time*10)*100 > 0 then
            bot.y = bot.y + bot.speed
        else
            bot.y = bot.y - bot.speed
        end
    end

    -- Bot's paddle limits
    if bot.y < 10 then
        bot.y = 10
    end

    if bot.y + bot.h > wh - 10 then
        bot.y = wh - 10 - bot.h
    end
end

function love.keypressed(k)
    if k == "space" then
        afk = not afk
    end
end

function love.draw()
    -- Miscs
    love.graphics.setColor(0,0,0.5)
    love.graphics.printf("Auto Mode: " .. tostring(afk), ww / 2, 10, ww / 2, "center")
    love.graphics.printf("Difficulty: " .. math.floor(winrate * 100), ww / 2, 30, ww / 2, "center")
    love.graphics.printf("Rate: " .. math.floor(rate), ww / 2, 50, ww / 2, "center")

    -- background
    love.graphics.setBackgroundColor(0.96, 0.96, 0.96)

    -- Draw the scores
    love.graphics.printf(points.bot, 0, wh/2, ww / 4, "center", 0, 2, 2)
    love.graphics.printf(points.player, ww / 2, wh/2, ww/4, "center", 0, 2, 2)

    -- Draw the center line
    love.graphics.setColor(0, 0, 0)
    love.graphics.line(ww / 2, 0, ww / 2, wh)

    -- Draw the ball
    love.graphics.setColor(1, 0.7, 0.3)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)

    -- Draw the paddles
    love.graphics.setColor(1, 0.3, 0)
    love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)

    love.graphics.setColor(0.3, 0, 1)
    love.graphics.rectangle("fill", bot.x, bot.y, bot.w, bot.h)
end
