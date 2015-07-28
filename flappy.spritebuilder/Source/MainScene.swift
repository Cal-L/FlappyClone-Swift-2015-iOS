import Foundation

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    var _scrollSpeed : CGFloat = 100
    var _bird : CCSprite!
    var _physicsNode : CCPhysicsNode!
    var _ground1 : CCSprite!
    var _ground2 : CCSprite!
    var _grounds : [CCSprite] = []
    var _sinceTouch : CCTime = 0
    var _obstacles : [CCNode] = []
    let _firstObstaclePosition : CGFloat = 280
    let _distanceBetweenObstacles : CGFloat = 160
    var _obstaclesLayer : CCNode!
    var _restartButton : CCButton!
    var _gameOver = false
    var _points : NSInteger = 0
    var _scoreLabel : CCLabelTTF!
    
    func didLoadFromCCB() {
        _grounds.append(_ground1)
        _grounds.append(_ground2)
        self.userInteractionEnabled = true;
        self.spawnNewObstacle()
        self.spawnNewObstacle()
        self.spawnNewObstacle()
        _physicsNode.collisionDelegate = self
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, bird nodeA: CCNode!, level nodeB: CCNode!) -> Bool {
        NSLog("TODO: GAME OVER")
        self.gameOver()
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, bird: CCNode!, goal: CCNode!) -> Bool {
        goal.removeFromParent()
        _points++
        _scoreLabel.string = String(_points)
        return true
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (_gameOver == false) {
            _bird.physicsBody.applyImpulse(ccp(0,400))
            _bird.physicsBody.applyAngularImpulse(10000)
            _sinceTouch = 0
        }
    }
    
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
    }
    
    override func update(delta: CCTime) {
        _bird.position = ccp(_bird.position.x + _scrollSpeed * CGFloat(delta), _bird.position.y);
        _physicsNode.position = ccp(_physicsNode.position.x - _scrollSpeed * CGFloat(delta), _physicsNode.position.y)
        for ground in _grounds {
            let groundWorldPosition = _physicsNode.convertToWorldSpace(ground.position)
            let groundScreenPosition = self.convertToNodeSpace(groundWorldPosition)
            if groundScreenPosition.x <= (-ground.contentSize.width) {
                ground.position = ccp(ground.position.x + ground.contentSize.width * 2, ground.position.y)
            }
        }
        let velocityY = clampf(Float(_bird.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        _bird.physicsBody.velocity = ccp(0, CGFloat(velocityY))
        _sinceTouch += delta
        _bird.rotation = clampf(_bird.rotation, -30, 90)
        if (_bird.physicsBody.allowsRotation) {
            let angularVelocity = clampf(Float(_bird.physicsBody.angularVelocity), -2, 1)
            _bird.physicsBody.angularVelocity = CGFloat(angularVelocity)
        }
        if (_sinceTouch > 0.5) {
            let impulse = -20000.0 * delta
            _bird.physicsBody.applyAngularImpulse(CGFloat(impulse))
        }
        
        for obstacle in _obstacles.reverse() {
            let obstacleWorldPosition = _physicsNode.convertToWorldSpace(obstacle.position)
            let obstacleScreenPosition = self.convertToNodeSpace(obstacleWorldPosition)
            
            //Obstacle moved past left side of screen?
            if obstacleScreenPosition.x < (-obstacle.contentSize.width) {
                obstacle.removeFromParent()
                _obstacles.removeAtIndex(find(_obstacles, obstacle)!)
                
                //For each removed obstacle, add a new one on the right
                self.spawnNewObstacle()
            }
        }
    }
    
    func gameOver() {
        if (_gameOver == false) {
            _gameOver = true
            _restartButton.visible = true
            _points = 0
            _scrollSpeed = 0
            _bird.rotation = 0
            _bird.physicsBody.allowsRotation = false
            _bird.stopAllActions()
            
            var move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.2, position: ccp(0,4)))
            var moveBack = CCActionEaseBounceOut(action: move.reverse())
            var shakeSequence = CCActionSequence(array: [move, moveBack])
            self.runAction(shakeSequence)
        }
    }
    
    func restart() {
        var scene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().replaceScene(scene)
    }
    
    func spawnNewObstacle() {
        var prevObstaclePos = _firstObstaclePosition
        if _obstacles.count > 0 {
            prevObstaclePos = _obstacles.last!.position.x
        }
        
        let obstacle = CCBReader.load("Obstacle") as Obstacle
        obstacle.position = ccp(prevObstaclePos + _distanceBetweenObstacles, 0)
        obstacle.setupRandomPosition()
        _obstaclesLayer.addChild(obstacle)
        _obstacles.append(obstacle)
    }
}
