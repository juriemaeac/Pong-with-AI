
push = require 'push'
Class = require 'class'
require 'Paddle' 
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

AI_HIT = 0

function love.load()
   
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')
    math.randomseed(os.time())
    smallFont = love.graphics.newFont('font.ttf', 10)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/pad_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    player1Score = 0
    player2Score = 0
    servingPlayer = 1

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 30, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'serve' then
     
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
            AI_HIT = math.random(2, 10)
        else
            ball.dx = -math.random(140, 200)
            AI_HIT = math.random(2, 10)
        end
    elseif gameState == 'play' then
        
        if ball.dx > 0 then
            if ball.x > 100 then
                if AI_HIT < 7 then
                    if player2.y > ball.y then
                        player2.dy = -PADDLE_SPEED
                    elseif player2.y +40 < ball.y then     
                        player2.dy = PADDLE_SPEED       
                    else 
                        player2.dy = 0
                    end
                else
                    if player2.y - 3 > ball.y and player2.y - 0 > ball.y then
                        player2.dy = -PADDLE_SPEED
                    elseif player2.y +40 < ball.y and player2.y +23 < ball.y then     
                        player2.dy = PADDLE_SPEED       
                    else 
                        player2.dy = 0
                    end
                end
            end
        end

        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
            AI_HIT = math.random(1, 10)

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4
            player2.dy = 0
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        --up
        if ball.y <= 12 then
            ball.y = 12
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        --down
        if ball.y >= VIRTUAL_HEIGHT - 16 then
            ball.y = VIRTUAL_HEIGHT - 16
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        --right side
        if ball.x < 12 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
    
                ball:reset()
            end
        end

        --left side
        if ball.x > VIRTUAL_WIDTH - 12 then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()

            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)

    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'

            ball:reset()

            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()

    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 1)

    love.graphics.setFont(smallFont)
    
	--border
    love.graphics.rectangle("line", 5, 5, VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 15, segments)
	love.graphics.setLineWidth(2)
    displayScore()

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!",
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        love.graphics.line(215, 232, 215, 6)
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 150, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 170, VIRTUAL_WIDTH, 'center')
    end

    player1:render()
    player2:render()
    ball:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()

    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end
