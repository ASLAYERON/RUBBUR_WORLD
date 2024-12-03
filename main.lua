love.window.setFullscreen( false )
local SCREEN_W,SCREEN_H = love.graphics.getDimensions()
SCREEN_W = 1.4*SCREEN_H
love.window.setMode(SCREEN_W, SCREEN_H)
local Xpix = SCREEN_W/100
local Ypix = SCREEN_H/100
local yPLAYER = SCREEN_H/2
local PLAYERrayon = 5.35*Xpix
local BALLrayon = 5.35*Xpix
local state = "start"
local level = 1
local xPLAYER = 20*Xpix
local mouse = 0
local press = 0
local gravity = 100
local boost = 200
local a = 100
local v = 0
local xBack1 = 0
local xBack2 = SCREEN_W
local xFront1 = 0
local xFront2 = SCREEN_W
local random = 0
local sablier = 0
local score = 0
local sablier_speed = 3
local sablierBALL = 0
local secu = 0
local physics_boost = 1
local pausetime=0

local scroll_speed = 100
local STARTx = SCREEN_W/2-20*Xpix
local STARTy = SCREEN_H/2-15*Ypix
local STARTxScale = 40*Xpix
local STARTyScale = 15*Ypix

local RECOMMENCERx = 30*Xpix
local RECOMMENCERy = 70*Ypix
local RECOMMENCERxScale = 40*Xpix
local RECOMMENCERyScale = 15*Ypix

local BLOCS = 
{
    --1
    {
        x = -16*Xpix,
        y = 60*Ypix,
        xScale = 15*Xpix,
        yScale = 40*Ypix,
        texture = love.graphics.newImage("assets/1.png")
},
    --2
    {
        x = -16*Xpix,
        y = 40*Ypix,
        xScale = 15*Xpix,
        yScale = 60*Ypix,
        texture = love.graphics.newImage("assets/2.png")  
    },
    --3
    {
        x = -16*Xpix,
        y = 0*Ypix,
        xScale = 15*Xpix,
        yScale = 50*Ypix,
        texture = love.graphics.newImage("assets/3.png")
    },
    --4
    {
        x = -16*Xpix,
        y = 0*Ypix,
        xScale = 15*Xpix,
        yScale = 60*Ypix,
        texture = love.graphics.newImage("assets/2.png")  
    },
    --5
    {
        x = -16*Xpix,
        y = 40*Ypix,
        xScale = 15*Xpix,
        yScale = 20*Ypix,
        texture = love.graphics.newImage("assets/5.png")
    }
}
local BALLS =
{
    --1
    {
        x= -11*Xpix,
        y = 21*Ypix,
        tilt = 0,
    },
    --2
    {
        x= -11*Xpix,
        y = 54*Ypix,
        tilt = 0,
    },
    --3
    {
        x= -11*Xpix,
        y = 81*Ypix,
        tilt = 0,
    },
}



local BACKGROUND_START = love.graphics.newImage("assets/start.png")
local BOUTON_START = love.graphics.newImage("assets/BOUTON_START.png")
local RECOMMENCER = love.graphics.newImage("assets/RECOMMENCER.png")
local BACKGROUND1 = love.graphics.newImage("assets/background.png")
local BACKGROUND2 = love.graphics.newImage("assets/background.png")
local FRONTGROUND1 = love.graphics.newImage("assets/frontground.png")
local FRONTGROUND2 = love.graphics.newImage("assets/frontground.png")
local PAUSE = love.graphics.newImage("assets/PAUSE.png")
local texture = love.graphics.newImage("assets/1.png")
local PLAYER = love.graphics.newImage("assets/player.png")
local BALL = love.graphics.newImage("assets/ball.png")
local GAME_OVER = love.graphics.newImage("assets/GAME_OVER.png")
local LEVEL_2 = love.graphics.newImage("assets/level2.png")
local LEVEL_3 = love.graphics.newImage("assets/level3.png")
local music1 = love.audio.newSource( "assets/RUBBUR_WORLD1.mp3", "static" )
local music2 = love.audio.newSource( "assets/RUBBUR_WORLD2.mp3", "static" )
local music3 = love.audio.newSource( "assets/RUBBUR_WORLD3.mp3", "static" )
music1:setLooping( true )
music2:setLooping( true )
music3:setLooping( true )
music1:play()
love.audio.setVolume( 0 )
function love.load()
    state="start"
    mouse=0
    yPLAYER=SCREEN_H/2
    press=0
    gravity=100
    boost=200
    a=100
    v=0
    xBack1 = 0
    xBack2 = SCREEN_W
    xFront1 = 0
    xFront2 = SCREEN_W
    for BLOCnum = 1,5,1 do
        BLOCS[BLOCnum].x = -16*Xpix
    end
    for BALLnum = 1,3,1 do
        BALLS[BALLnum].x = -10*Xpix
    end
    scroll_speed = 100
    score = 0
    level = 1
end

local function testHitboxPoint(xSubject,ySubject,x,y,xScale,yScale)
    if xSubject >= x and xSubject <= x+xScale and ySubject >= y and ySubject<= y+yScale then
        return true
    end
    return false
end

local function testHitboxRectangle(x1,y1,xScale1,yscale1,x2,y2,xScale2,yScale2)
    if x1 <= x2+xScale2 and x1+xScale1 >= x2 and y1<y2+yScale2 and y1+yscale1>y2 then
        return true
    end
    return false
end

local function testHitboxRondRectangle(xCentre,yCentre,rayon,x2,y2,xScale2,yScale2)
    if xCentre-rayon <= x2+xScale2 and xCentre+rayon >= x2 and yCentre-rayon<=y2+yScale2 and yCentre+rayon>y2 then

        if xCentre <= x2 and yCentre <= y2 then
            if math.sqrt(math.pow(x2-xCentre,2)+math.pow(y2-yCentre,2))>=rayon then
                return false
            else
                return true
            end

        elseif xCentre >= x2+xScale2 and yCentre <= y2+yScale2 then
            if math.sqrt(math.pow((x2-xScale2)-xCentre,2)+math.pow(y2-yCentre,2))>=rayon then
                return false
            else
                return true
            end

        elseif xCentre-rayon >= x2+xScale2 and yCentre-rayon>=y2+yScale2 then
            if math.sqrt(math.pow((x2+xScale2)-xCentre,2)+math.pow((y2+yScale2)-yCentre,2))>=rayon then
                return false
            else
                return true
            end

        elseif xCentre <= x2 and yCentre >= y2+yScale2 then
            if math.sqrt(math.pow(x2-xCentre,2)+math.pow((y2+yScale2)-yCentre,2))>=rayon then
                return false
            else
                return true
            end
        else
            return true
        end
    else 
        return false
    end

end
local function testHitboxRond(xCentre1,yCentre1,rayon1,xCentre2,yCentre2,rayon2)
    if math.sqrt(math.pow(xCentre2-xCentre1,2)+math.pow(yCentre2-yCentre1,2))<=rayon1+rayon2 then
        return true
    else
        return false
    end
end
local function physiquePLAYER(dt)
    gravity=300+scroll_speed*dt+(level-1)*70
    boost = 0
    if press==1 then
        boost=-600-scroll_speed*dt-(level-1)*150
    end

    a=gravity+boost
    v=v+a*dt*physics_boost
    if yPLAYER>=5*Ypix then
        if yPLAYER<=80*Ypix then
            yPLAYER=yPLAYER+v*dt
        else
            yPLAYER=79*Ypix
            v=-v
        end
    else
        state="game_over"
    end
end


function love.mousepressed( x, y)

    if state == "start" then
        if testHitboxPoint(x,y,STARTx,STARTy,STARTxScale,STARTyScale) then
            state = "play"
            music1:play()
        end
    end
    if state == "game_over" then
        love.load()
    end

    mouse=1
end

function love.mousereleased()
    mouse=0
end

function love.update(dt)



    --check boutons
    pausetime=pausetime+dt
    if love.keyboard.isDown( "escape" ) then
        print("exit")
        love.event.quit()
    end
    if love.keyboard.isDown( "space" ) and state=="game_over" then
        love.load()
    end
    if love.keyboard.isDown( "p" ) then
        if state=="play" and pausetime>0.5 then
            state="pause"
            pausetime=0
        elseif state=="pause" and pausetime>0.5 then
            state="play"
            pausetime=0
        end
    end

    press=0
    if love.keyboard.isDown("space") or mouse==1 then
        press=1
    end

    if state=="play" then

        physiquePLAYER(dt)

        --defilement
        if xFront1<=-100*Xpix then
            xFront1=SCREEN_W
        end
        if xFront2<=-100*Xpix then
            xFront2=SCREEN_W
        end
        if xBack1<=-100*Xpix then
            xBack1=SCREEN_W
        end
        if xBack2<=-100*Xpix then
            xBack2=SCREEN_W
        end
        xFront1=xFront1-scroll_speed*dt
        xFront2=xFront2-scroll_speed*dt
        xBack1=xBack1-scroll_speed*dt/2
        xBack2=xBack2-scroll_speed*dt/2

        sablier=sablier+scroll_speed*dt
        sablier_speed = (450+(level-1)*50)*SCREEN_W/700

        if sablier>=sablier_speed then
            sablier=0
            random = love.math.random(1,5)

            for BLOCnum = 1,5,1 do
                if random == BLOCnum then
                    if BLOCS[BLOCnum].x <= -15*Xpix then
                        BLOCS[BLOCnum].x = 110*Xpix
                        if BLOCnum == 4 then
                            secu=1
                        else
                            secu=0
                        end
                    else
                        sablier=sablier_speed

                    end
                end
            end

        end
      for BLOCnum = 1,5,1 do
            if BLOCS[BLOCnum].x>=-16*Xpix then
                BLOCS[BLOCnum].x=BLOCS[BLOCnum].x-scroll_speed*dt

                if testHitboxRondRectangle(xPLAYER,yPLAYER,PLAYERrayon,BLOCS[BLOCnum].x,BLOCS[BLOCnum].y,BLOCS[BLOCnum].xScale,BLOCS[BLOCnum].yScale) then
                    state = "game_over"
                end
            end
        end

        if level >=2 then
            sablierBALL=sablierBALL+scroll_speed*dt
            if sablierBALL>=sablier_speed*3 then
                sablierBALL=0
                random = love.math.random(1,3)

                for BALLnum = 1,3,1 do
                    if random == BALLnum then
                        if BALLS[BALLnum].x <= -10*Xpix then
                            if BALLnum == 3 and secu == 1 then
                                sablierBALL=sablier_speed
                            else
                                BALLS[BALLnum].x = 110*Xpix
                            end
                        else
                            sablierBALL=sablier_speed

                        end
                    end
                end

            end
            if level >= 2 then
                for BALLnum = 1,3,1 do
                    if BALLS[BALLnum].x>=-16*Xpix then
                        BALLS[BALLnum].x=BALLS[BALLnum].x-scroll_speed*dt*2
                        BALLS[BALLnum].tilt=BALLS[BALLnum].tilt-(scroll_speed/30)*dt
                        if testHitboxRond(xPLAYER,yPLAYER,PLAYERrayon,BALLS[BALLnum].x,BALLS[BALLnum].y,BALLrayon) then
                            state = "game_over"
                            print("hehe c moi batard")
                        end
                    end
                end
            end
        end
        score=score+dt
        scroll_speed=(100+5*score)*(SCREEN_W/700)
    end
    if level == 1 and score >= 30 then
        state = "level_up"
        level=2
        music1:stop()
        music2:play()
        physics_boost=2
        sablier=0
        scroll_speed=200
    end

    if level == 2 and score >= 60 then
        state = "level_up"
        level=3
        music2:stop()
        music3:play()
        physics_boost=2.5
        sablier=0
        scroll_speed=300
    end

    if state=="level_up" then
        sablier=sablier+dt
        if sablier>=1.5 then
            state="play"
        end
    end
end

function love.draw()

    if state=="start" then
        love.graphics.draw(BACKGROUND_START,0,0,0,0.5*SCREEN_W/700,0.5*SCREEN_H/500)
        love.graphics.draw(BOUTON_START,STARTx,STARTy,0,0.5*SCREEN_W/700,0.5*SCREEN_H/500)

    elseif state=="play" then

 
        if level >=2 then
            love.graphics.setColor(0,1,1,1)
        end
        if level >=3 then
            love.graphics.setColor(1,0,1,1)
        end
        love.graphics.draw(BACKGROUND1,xBack1,0,0,0.505*SCREEN_W/700,0.5*SCREEN_H/500)
        love.graphics.draw(BACKGROUND2,xBack2,0,0,0.505*SCREEN_W/700,0.5*SCREEN_H/500)
        love.graphics.draw(FRONTGROUND1,xFront1,0,0,0.505*SCREEN_W/700,0.5*SCREEN_H/500)
        love.graphics.draw(FRONTGROUND2,xFront2,0,0,0.505*SCREEN_W/700,0.5*SCREEN_H/500)
        SCORE="SCORE :"..tostring(math.floor(score+0.5))
        --love.graphics.circle("fill",xPLAYER,yPLAYER,PLAYERrayon)
        love.graphics.setColor(1,1,1,1)
        for BLOCnum = 1,5,1 do
            love.graphics.draw(BLOCS[BLOCnum].texture,BLOCS[BLOCnum].x,BLOCS[BLOCnum].y,0,0.5*SCREEN_W/700,0.5*SCREEN_H/500)
        end
        if level >=2 then
            for BALLnum = 1,3,1 do
                love.graphics.draw(BALL,BALLS[BALLnum].x,BALLS[BALLnum].y,BALLS[BALLnum].tilt,0.5*SCREEN_W/700,0.5*SCREEN_H/500,75,75)
            end
        end
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(PLAYER,xPLAYER,yPLAYER,math.deg(v/10000),0.5*SCREEN_W/700,0.5*SCREEN_H/500,75,75)
        love.graphics.setColor(0,0,0,1)
        love.graphics.print(SCORE,SCREEN_W-20*Xpix,0,0,0.3*Xpix)
        love.graphics.setColor(1,1,1,1)

    elseif state =="game_over" then
        music2:stop()
        music3:stop()
        music1:stop()

        love.graphics.draw(GAME_OVER,0,0,0,0.5*SCREEN_W/700,0.5*SCREEN_H/500)
        love.graphics.draw(RECOMMENCER,30*Xpix,70*Ypix,0,0.5*SCREEN_W/700,0.5*SCREEN_H/500)
        love.graphics.print("SCORE:",28*Xpix,50*Ypix,0,0.8*Xpix)
        love.graphics.print((math.floor(score+0.5)),65*Xpix,50*Ypix,0,0.8*Xpix)

    elseif state =="level_up" then
        if level==2 then
            love.graphics.setColor(0,1,1,1)
            love.graphics.draw(BACKGROUND1,xBack1,0,0,0.505*SCREEN_W/700,0.5*SCREEN_H/500)
            love.graphics.draw(BACKGROUND2,xBack2,0,0,0.505*SCREEN_W/700,0.5*SCREEN_H/500)
            love.graphics.draw(FRONTGROUND1,xFront1,0,0,0.505*SCREEN_W/700,0.5*SCREEN_H/500)
            love.graphics.draw(FRONTGROUND2,xFront2,0,0,0.505*SCREEN_W/700,0.5*SCREEN_H/500)
            love.graphics.setColor(1,1,1,1)
            love.graphics.draw(PLAYER,xPLAYER,yPLAYER,math.deg(v/10000),0.5*SCREEN_W/700,0.5*SCREEN_H/500,75,75)
            love.graphics.draw(LEVEL_2,0,0,0,0.505*SCREEN_W/700,0.5*SCREEN_H/500)
        elseif level==3 then
            love.graphics.setColor(1,0,1,1)
            love.graphics.draw(BACKGROUND1,xBack1,0,0,0.505*SCREEN_W/700,0.5*SCREEN_H/500)
            love.graphics.draw(FRONTGROUND1,xFront1,0,0,0.505*SCREEN_W/700,0.5*SCREEN_H/500)
            love.graphics.draw(FRONTGROUND2,xFront2,0,0,0.5050*SCREEN_W/700,0.5*SCREEN_H/500)
            love.graphics.setColor(1,1,1,1)
            love.graphics.draw(PLAYER,xPLAYER,yPLAYER,math.deg(v/10000),0.5*SCREEN_W/700,0.5*SCREEN_H/500,75,75)
            love.graphics.draw(LEVEL_3,0,0,0,0.505*SCREEN_W/700,0.5*SCREEN_H/500)
        end
    end
    if state=="pause" then
        love.graphics.draw(PAUSE,0,0,0,0.5*SCREEN_W/700,0.5*SCREEN_H/500)
    end  

end