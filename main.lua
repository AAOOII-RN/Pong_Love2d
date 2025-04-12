function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    math.randomseed(os.time())
    love.window.setMode(1080, 800)

    ww, wh = love.window.getMode()

    font = love.graphics.newFont("Exo.ttf")
    love.graphics.setFont(font)

    ball = {
        x = ww/2,
        y = wh/2,
        radius = 15,
        speed = {
            x = math.random(0, 1) == 0 and -1 or 1,
            y = math.random(0, 1) == 0 and -1 or 1
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

    afk = false
end

function ball_reset()
    ball.x = ww/2
    ball.y = wh/2
    ball.speed.x = math.random(0, 1) == 0 and -1 or 1
    ball.speed.y = math.random(0, 1) == 0 and -1 or 1
end

function love.update(dt)
    ball.x = ball.x + ball.speed.x * 300 * dt
    ball.y = ball.y + ball.speed.y * 300 * dt

    time = time + 1 * dt
    winrate = points.player / (points.player + points.bot)

    -- Check window ends
    if ball.x + ball.radius >= ww then
        ball_reset()
        points.bot = points.bot + 1
    end
    
    -- check goal
    if ball.x - ball.radius <= 0  then
        ball_reset()
        points.player = points.player + 1
    end

    if ball.y + ball.radius >= wh then
        ball.speed.y = -math.abs(ball.speed.y)
    end

    if ball.y - ball.radius <= 0  then
        ball.speed.y = math.abs(ball.speed.y)
    end

    -- Check paddles' collision
    if ball.x + ball.radius >= player.x and ball.y >= player.y and ball.y <= player.y + player.h then
        ball.speed.x = -math.abs(ball.speed.x)
    end

    if ball.x - ball.radius <= bot.x + bot.w and ball.y >= bot.y and ball.y <= bot.y + bot.h then
        ball.speed.x = math.abs(ball.speed.x)
    end

     -- switch afk
     if love.keyboard.isDown("q") then
        afk = true
    elseif love.keyboard.isDown("e") then
        afk = false
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
            if ball.y < player.y + player.h / 2 then
                player.y = player.y - player.speed
            end
        
            if ball.y > player.y + player.h / 2 then
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
        if botFocus.y < bot.y + bot.h / 2 then
            bot.y = bot.y - bot.speed
        end
    
        if botFocus.y > bot.y + bot.h / 2 then
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

function love.draw()
    -- Auto mode
    love.graphics.printf("Auto Mode: " .. tostring(afk), ww / 2, wh/8, ww / 2, "center")

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
