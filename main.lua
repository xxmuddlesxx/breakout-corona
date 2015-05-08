display.setStatusBar(display.HiddenStatusBar)

local physics = require('physics')
physics.start()

-- Set gravity parameters --> physics.geGravity(gx, gy), x and y of 
-- global gravity vector, default is 0, 9.8 to simulate earth gravity
physics.setGravity(0, 0)

-- physics.get
-- gx, gy = physics.getGravity()
--


function movePaddle(event)
    paddle.x = display.contentCenterX - (display.contentCenterX *
                                                        (event.yGravity*3))
end

Runtime:addEventListener("accelerometer", movePaddle)

-- This sets the internal pixel-per-meter ratio for converting Corona
-- coordinates and simulated physical environments
physics.setScale(60)

-- debug, hybrid, normal
physics.setDrawMode(mode)

--[[Orange—dynamic physics bodies (the default body type)
Dark blue—kinematic physics bodies
Green—static physics bodies such as the ground or walls
Gray—a body that is sleeping due to lack of activity
Light blue—joints
]]--

--This function sets the accuracy of the engine's position calculations.
physics.setPositionIterations(16)

-- This function sets the accuracy of the engine's velocity calculations. 
physics.setVelocityIterations(6)

-- Groups allow you to add and remove child display objects.
-- display.newGroup(), Creates a group
local rect = display.newRect(0, 0, 150,150)
rect:setFillColor(255,255,255)

local myGroup = display.newGroup()
myGroup:insert(rect)

print (system.getInfo("name") )

system.setAccelerometerInterval(75)

--[[
Necessary Classes (For example: physics or ui) Variables and Constants
Main Function
Object Methods
Call Main Function (This always has to be called or your application will not run)]]--


--[[local menuScreenGroup, local alertDisplayGroup, and local bricks are all forms of display groups we can separate and organize our display objects to. ]]--

local menuScreenGroup 
local mmScreen
local playBtn
local helpBtn

local background
local paddle
local brick
local ball

local scoreText
local scoreNum
local levelText
local levelNum

local alertDisplayGroup
local alertBox
local conditionDisplay
local messageText

local _W = display.contentWidth / 2
local _H = display.contentHeight / 2
local bricks = display.newGroup()
local brickWidth = 35
local brickHeight = 15
local row
local column
local score = 0
local scoreIncrease = 100
local currentLevel

local vx = 3
local vy = -3

local gameEvent = ""

local isSimulator = "simulator" == system.getInfo("environment")

function main()
    mainMenu()
end

function mainMenu()
    menuScreenGroup = display.newGroup()
    mmScreen = display.newImage("assets/img/mmScreen.png", 0, 0, true)
    mmScreen.x = _W
    mmScreen.y = _H

    playBtn = display.newImage("assets/img/playbtn.png")
    playBtn.anchorX = _W
    playBtn.anchorY = _H
    playBtn.x = _W; playBtn.y = _H + 50
    playBtn.name = "playbutton"

    helpBtn = display.newImage("assets/img/ball.png")
    helpBtn.x = _W / 2;
    helpBtn.y = _H * 2 - 10;
    helpBtn.name = "helpbutton"

    menuScreenGroup:insert(mmScreen)
    menuScreenGroup:insert(playBtn)

    playBtn:addEventListener("tap", loadGame)
    helpBtn:addEventListener("tap", helpScreen)
end

function loadGame(event)
    if event.target.name == 'playbutton' then
        transition.to(menuScreenGroup, {time = 0, alpha = 0, onComplete = addGameScreen})
        playBtn:removeEventListener("tap", loadGame)
    end
end

function helpScreen(event)
    if event.target.name == 'helpbutton' then
        --transition.to(menuScreenGroup, {time=0, alpha=0, onComplete=addGameScreen})
        print ('Help was pressed')
        helpBtn:removeEventListener("tap", helpScreen)
    end
end

function addGameScreen()
    background = display.newImage("assets/img/bg.png", 0, 0, true)
    background.x = _W
    background.y = _H

    paddle = display.newImage("assets/img/paddle.png")
    paddle.x = 240; paddle.y = 300
    paddle.name = "paddle"

    ball = display.newImage("assets/img/ball.png")
    ball.x = 240; ball.y = 290
    ball.name = "ball"

    scoreText = display.newText("Score:", 5, 2, "Arial", 14)
    scoreText:setTextColor(255,255,255,255)

    scoreNum = display.newText("0", 54, 2, "Arial", 14)
    scoreNum:setTextColor(255, 255, 255, 255)

    levelText = display.newText("Level:", 420, 2, "Arial", 14)
    levelText:setTextColor(255, 255, 255, 255)

    levelNum = display.newText("1", 460, 2, "Arial", 14)
    levelNum:setTextColor(255, 255, 255, 255)

    gameLevel1()
    background:addEventListener("tap", startGame)
end

function dragPaddle(event)
        if event.phase == 'began' then
            moveX = event.x - paddle.x
        elseif event.phase == "moved" then
            paddle.x = event.x - moveX
        end

        if ( (paddle.x - paddle.width * 0.5) < 0) then
            paddle.x = paddle.width * 0.5
        elseif ((paddle.x + paddle.width * 0.5) > display.contentWidth) then
            paddle.x = display.contentWidth - paddle.width * 0.5
        end
end

function movePaddle(event)
    paddle.x = display.contentCenterX - (display.contentCenterX * (event.yGravity*3))
    if ( (paddle.x - paddle.width * 0.5) < 0) then
        paddle.x = paddle.width * 0.5
    elseif ((paddle.x + paddle.width  * 0.5) > display.contentWidth) then
        paddle.x = display.contentWidth - paddle.width * 0.5
    end
end

function bounce()
    vy = -3
    if ((ball.x + ball.width * 0.5) < paddle.x) then
        vx= -vx
    elseif ((ball.x + ball.width * 0.5) >= paddle.x) then
        vx=vx
    end
end

function startGame()
    physics.addBody(paddle, "static", {density=1,friction=0,bounce=0})
    physics.addBody(ball, "dynamic", {density=1,friction=0,bounce=0})
    background:removeEventListener("tap", startGame)

    gameListeners("add")
end


function gameLevel1()
    currentLevel = 1
    bricks:toFront()

    local numOfRows = 4
    local numOfColumns = 4
    local brickPlacement = { x = (_W) - (brickWidth * numOfColumns) / 2 + 20, y=50}

    for row=0, numOfRows - 1 do
        for column = 0, numOfColumns - 1 do
            local brick = display.newImage("assets/img/brick.png")
            brick.name = "brick"
            brick.x = brickPlacement.x + (column * brickWidth)
            brick.y = brickPlacement.y + (row * brickHeight)
            physics.addBody(brick, "static", {density=1, friction=0,
                                                                bounce=0})
            bricks.insert(bricks,brick)
        end
    end
end

function gameLevel2()
    currentLevel = 2
    bricks:toFront()

    local numOfRows = 5
    local numOfColumns = 8 
    local brickPlacement = {x = (_W) - (brickWidth * numOfColumns) / 2 + 20,                                                            y=50}
    for row = 0, numOfRows - 1 do
        for column = 0, numOfColumns - 1 do
            local brick = display.newImage("assets/img/brick.png")
            brick.name = "brick"
            brick.x = brickPlacement.x + (column * brickWidth)
            brick.y = brickPlacement.y + (row * brickHeight)
            physics.addBody(brick, "static", {density=1, friction=0,
                                                                bounce=0})
            bricks.insert(bricks,brick)
        end
    end
end

function gameListeners(event)
    if event == 'add' then
        Runtime:addEventListener("accelerometer", movePaddle)
        Runtime:addEventListener("enterFrame", updateBall)
        paddle:addEventListener("collision", bounce)
        ball:addEventListener("collision", removeBrick)
        paddle:addEventListener("touch", dragPaddle)
    elseif event == 'remove' then
        Runtime:removeEventListener("accelerometer", movePadle)
        Runtime:removeEventListener("enterFrame", updateBall)
        paddle:removeEventListener("collision", bounce)
        ball:removeEventListener("collision", removeBrick)
        paddle:removeEventListener("touch", dragPaddle)
    end
end


function removeBrick(event)
    if event.other.name == 'brick' and ball.x + ball.width * 0.5 < event.other.x + event.other.width * 0.5 then
        vx = -vx
    elseif event.other.name == 'brick' and ball.x + ball.width  * 0.5 >= event.other.x + event.other.width * 0.5 then
        vx = vx
    end

    if event.other.name == 'brick' then
        vy = vy * -1
        event.other:removeSelf()
        event.other = nil
        bricks.numChildren = bricks.numChildren - 1
        score = score + 1
        scoreNum.text = score * scoreIncrease
        scoreNum.anchorX = _W*.3
		scoreNum.anchorY = _H*.3
        scoreNum.x = 54
    end

    if bricks.numChildren <= 0 then
        alertScreen("You win!", "Continue")
        gameEvent = "win"
    end
end

function updateBall()
    ball.x = ball.x + vx
    ball.y = ball.y + vy

    if ball.x < 0 or ball.x + ball.width > display.contentWidth then
        vx = -vx
    end

    if ball.y < 0 then
        vy = -vy
    end

    if ball.y + ball.height > paddle.y + paddle.height then
        alertScreen("You lose!", "Play again")
        gameEvent = "lose"
    end
end

function changeLevel1()
    bricks:removeSelf()
    bricks.numChildren = 0
    bricks = display.newGroup()

    alertBox:removeEventListener("tap", restart)
    alertDisplayGroup:removeSelf()
    alertDisplayGroup = nil

    ball.x = (display.contentWidth * 0.5) - (ball.width * 0.5)
    ball.y = (paddle.y - paddle.height) - (ball.height * 0.5) - 2
    paddle.x = display.contentWidth * 0.5

    gameLevel1()
    background:addEventListener("tap", startGame)
end

function changeLevel2()
    bricks:removeSelf()
    bricks.numChildren = 0
    bricks = display.newGroup()

    alertBox:removeEventListener("tap", restart)
    alertDisplayGroup:removeSelf()
    alertDisplayGroup = nil

    ball.x = (display.contentWidth * 0.5) - (ball.width * 0.5)
    ball.y = (paddle.y - paddle.height) - (ball.height * 0.5) - 2
    paddle.x = display.contentWidth * 0.5

    gameLevel2()
    background:addEventListener("tap", startGame)
end

function alertScreen(title, message)
    alertBox = display.newImage("assets/img/alertBox.png")
    alertBox.x = 240; alertBox.y = 160

    transition.from(alertBox, {time=500,xScale=0.5,yScale=0.5,transition=easing.outExpo})

    conditionDisplay = display.newText(title, 0, 0, "Arial", 38)
    conditionDisplay:setTextColor(255,255,255,255)
    conditionDisplay.xScale = 0.5
    conditionDisplay.yScale = 0.5
    conditionDisplay.anchorX = _W
    conditionDisplay.anchorY = _H
    conditionDisplay.x = display.contentCenterX
    conditionDisplay.y = display.contentCenterY - 15

    messageText = display.newText(message, 0, 0, "Arial", 24)
    messageText:setTextColor(255,255,255,255)
    messageText.xScale = 0.5
    messageText.yScale = 0.5
    messageText.anchorX = _W
    messageText.anchorY = _H
    messageText.x = display.contentCenterX
    messageText.y = display.contentCenterY + 15

    alertDisplayGroup = display.newGroup()
    alertDisplayGroup:insert(alertBox)
    alertDisplayGroup:insert(conditionDisplay)
    alertDisplayGroup:insert(messageText)

    alertBox:addEventListener("tap", restart)

    gameListeners("remove")
end

function restart()
    if gameEvent == 'win' and currentLevel == 1 then
        currentLevel = currentLevel + 1
        changeLevel2()
        -- tostring converts any argument to a string
        levelNum.text = tostring(currentLevel)
    elseif gameEvent == 'win' and currentLevel == 2 then
        alertScreen("  Game Over", "  Congratulations!")
        gameEvent = "completed"
    elseif gameEvent == 'lose'and currentLevel == 1 then
        score = 0
        scoreNum.text = "0"
        changeLevel1()
    elseif gameEvent == 'lose' and currentLevel == 2 then
        score = 0
        scoreNum.text = "0"
        changeLevel2()
    elseif gameEvent == "completed" then
        alertBox:removeEventListener("tap", restart)
    end
end


main()
