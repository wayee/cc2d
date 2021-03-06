﻿package cc.move
{
	import cc.CCCharacter;
	import cc.define.AvatarPartType;
	import cc.define.CharAngleType;
	import cc.define.CharStatusType;
	import cc.events.CCEvent;
	import cc.events.CCEventActionWalk;
	import cc.tools.SceneCache;
	import cc.utils.SceneUtil;
	import cc.vo.avatar.AvatarPlayCondition;
	import cc.vo.map.MapTile;
	
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Linear;
	
	import flash.geom.Point;
	
	import wit.event.EventDispatchCenter;
	import wit.handler.HandlerHelper;
	import wit.utils.math;

    public class Jump
	{
        public static function jump(p_char:CCCharacter, p_pos:Point, p_speed:Number=-1, p_max_dis:Number=-1, p_vars:Object=null):void {
            var mapTile:MapTile = null;
            var evt:CCEvent = null;
            var p1:Point = null;
            var hasSolid:Boolean = false;
            var tm:* = null;
            var sceneChar:CCCharacter = p_char;
            var tilePos:Point = p_pos;
            var speed:Number = p_speed;
            var maxDis:int = p_max_dis;
            var vars:Object = p_vars;
			
            if (sceneChar.isJumping()) {
                return;
            }
			
            sceneChar.moveData.clear();
            var fromTile:MapTile = SceneCache.MapTiles[((sceneChar.TileX + "_") + sceneChar.TileY)];
            mapTile = SceneCache.MapTiles[((tilePos.x + "_") + tilePos.y)];
            if (mapTile == null){
                return;
            }
			
            if ( sceneChar.TileX == tilePos.x && sceneChar.TileY == tilePos.y ) {
                if (sceneChar == sceneChar.scene.mainChar) {
                    sceneChar.scene.HideMouseChar();
                    evt = new CCEvent(CCEvent.WALK, CCEventActionWalk.JUMP_ARRIVED, [sceneChar, mapTile]);
                    EventDispatchCenter.getInstance().dispatchEvent(evt);
                }
                if ( vars != null && vars.onJumpArrived != null ) {
                    vars.onJumpArrived(sceneChar, mapTile);
                }
                return;
            }
            var p0:Point = new Point(sceneChar.PixelX, sceneChar.PixelY);
            p1 = new Point(mapTile.PixelX, mapTile.PixelY);
            var angle:* = math.getTwoPointsAngle(p0, p1);
            var distance:* = Point.distance(p0, p1);
            sceneChar.moveData.clear();
            if (speed == -1){
                speed = sceneChar.moveData.jump_speed;
            }
            if (maxDis == -1){
                maxDis = sceneChar.moveData.jump_maxDis;
            }
            sceneChar.moveData.jump_targetP = tilePos;
            sceneChar.moveData.jump_vars = vars;
            if (speed == 0){
                return;
            }
            if (sceneChar == sceneChar.scene.mainChar){
                sceneChar.scene.ShowMouseChar(tilePos.x, tilePos.y);
                mapTile = SceneUtil.GetLineMapTile(fromTile, mapTile, maxDis);
                p1 = new Point(mapTile.PixelX, mapTile.PixelY);
                distance = Point.distance(p0, p1);
                evt = new CCEvent(CCEvent.WALK, CCEventActionWalk.SEND_JUMP_PATH, [sceneChar, fromTile, mapTile]);
                EventDispatchCenter.getInstance().dispatchEvent(evt);
            }
            if (sceneChar == sceneChar.scene.mainChar){
                evt = new CCEvent(CCEvent.WALK, CCEventActionWalk.JUMP_READY, [sceneChar, fromTile, mapTile]);
                EventDispatchCenter.getInstance().dispatchEvent(evt);
            }
            if (vars != null && vars.onJumpReady != null) {
                vars.onJumpReady(sceneChar, fromTile, mapTile);
            }
            hasSolid = SceneUtil.HasSolidBetween2MapTile(fromTile, mapTile);
            if (hasSolid){
                sceneChar.HideAvatarPartsByType(AvatarPartType.MOUNT);
            }
            sceneChar.HideAvatarPartsByType(AvatarPartType.WEAPON);
            angle = math.getNearAngel((angle - 90));
            sceneChar.playTo(CharStatusType.JUMP, CharAngleType[("ANGEL_" + angle)], -1, new AvatarPlayCondition(true, true));
            var middleX:* = ((p0.x + p1.x) * 0.5);
            var middleY:* = (((p0.y + p1.y) * 0.5) - 200);
            sceneChar.moveData.isJumping = true;
            sceneChar.specilizeX = sceneChar.PixelX;
            sceneChar.specilizeY = sceneChar.PixelY;
            var time:* = Math.max((distance / speed), 0.6);
            tm = TweenMax.to(sceneChar, time, {
                PixelX:p1.x,
                PixelY:p1.y,
                bezier:[{
                    specilizeX:middleX,
                    specilizeY:middleY
                }, {
                    specilizeX:p1.x,
                    specilizeY:p1.y
                }],
                ease:Linear.easeIn,
                onUpdate:function ():void{
                    if (sceneChar.usable == false){
//                        TweenMax.removeTween(tm);
                        return;
                    }
                    if (sceneChar.getStatus() == CharStatusType.DEATH){
                        if (sceneChar == sceneChar.scene.mainChar){
                            sceneChar.scene.HideMouseChar();
                        }
                        if (hasSolid){
                            sceneChar.ShowAvatarPartsByType(AvatarPartType.MOUNT);
                        };
                        sceneChar.ShowAvatarPartsByType(AvatarPartType.WEAPON);
                        sceneChar.moveData.clear();
                        sceneChar.setXY(sceneChar.PixelX, sceneChar.PixelY);
                        mapTile = SceneCache.MapTiles[((sceneChar.TileX + "_") + sceneChar.TileY)];
                        if (sceneChar == sceneChar.scene.mainChar){
                            evt = new CCEvent(CCEvent.WALK, CCEventActionWalk.JUMP_ARRIVED, [sceneChar, mapTile]);
                            EventDispatchCenter.getInstance().dispatchEvent(evt);
                        }
                        if ( vars != null && vars.onJumpArrived != null ) {
                            vars.onJumpArrived(sceneChar, mapTile);
                        }
//                        TweenMax.removeTween(tm);
                        return;
                    }
                },
				
                onComplete:function ():void{
                    if (sceneChar == sceneChar.scene.mainChar){
                        sceneChar.scene.HideMouseChar();
                    }
                    if (hasSolid){
                        sceneChar.ShowAvatarPartsByType(AvatarPartType.MOUNT);
                    }
                    sceneChar.ShowAvatarPartsByType(AvatarPartType.WEAPON);
                    sceneChar.setXY(p1.x, p1.y);
                    sceneChar.playTo(CharStatusType.STAND, -1, -1);
                    sceneChar.moveData.clear();
                    if (sceneChar == sceneChar.scene.mainChar){
                        evt = new CCEvent(CCEvent.WALK, CCEventActionWalk.JUMP_ARRIVED, [sceneChar, mapTile]);
                        EventDispatchCenter.getInstance().dispatchEvent(evt);
                    }
                    if ( vars != null && vars.onJumpArrived != null ) {
                        vars.onJumpArrived(sceneChar, mapTile);
                    }
                }
            });
        }
		
        public static function lineTo(p_char:CCCharacter, p_pos:Point, p_speed:Number, p_is_pet:Boolean=false, p_vars:Object=null):void {
            var mapTile:MapTile = null;
            var p1:Point = null;
            var easeFun:Function = null;
            var hasSolid:Boolean = false;
            var tm:* = null;
            var sceneChar:CCCharacter = p_char;
            var tilePos:Point = p_pos;
            var speed:Number = p_speed;
            var $isPetJump:Boolean = p_is_pet;
            var vars:Object = p_vars;
            sceneChar.moveData.clear();
            if (speed == 0){
                return;
            }
            var fromTile:MapTile = SceneCache.MapTiles[((sceneChar.TileX + "_") + sceneChar.TileY)];
            mapTile = SceneCache.MapTiles[((tilePos.x + "_") + tilePos.y)];
            if ((((fromTile == null)) || ((mapTile == null)))){
                return;
            }
            var p0:Point = new Point(sceneChar.PixelX, sceneChar.PixelY);
            p1 = new Point(mapTile.PixelX, mapTile.PixelY);
            var angle:* = math.getTwoPointsAngle(p0, p1);
            var distance:* = Point.distance(p0, p1);
            if ($isPetJump){
                hasSolid = SceneUtil.HasSolidBetween2MapTile(fromTile, mapTile);
                if (hasSolid){
                    sceneChar.visible = false;
                }
                angle = math.getNearAngel((angle - 90));
                sceneChar.playTo(CharStatusType.WALK, CharAngleType[("ANGEL_" + angle)], -1, new AvatarPlayCondition(true));
                easeFun = Linear.easeNone;
            } else {
                easeFun = Expo.easeOut;
            }
            sceneChar.moveData.isJumping = true;
            sceneChar.specilizeX = sceneChar.PixelX;
            sceneChar.specilizeY = sceneChar.PixelY;
            if (((!((vars == null))) && (!((vars.onLineReady == null))))){
                vars.onLineReady(sceneChar, fromTile, mapTile);
            }
            var time:* = ($isPetJump) ? Math.max((distance / speed), 0.7) : (distance / speed);
            tm = TweenMax.to(sceneChar, time, {
                PixelX:p1.x,
                PixelY:p1.y,
                specilizeX:p1.x,
                specilizeY:p1.y,
                ease:easeFun,
                onUpdate:function ():void{
                    if (sceneChar.usable == false){
//                        TweenMax.removeTween(tm);
                        return;
                    }
                    if (sceneChar.getStatus() == CharStatusType.DEATH){
                        sceneChar.moveData.clear();
                        if ($isPetJump){
                            if (hasSolid){
                                sceneChar.visible = true;
                            };
                        };
                        mapTile = SceneCache.MapTiles[((sceneChar.TileX + "_") + sceneChar.TileY)];
                        if (((!((vars == null))) && (!((vars.onLineArrived == null))))){
                            vars.onLineArrived(sceneChar, mapTile);
                        };
//                        TweenMax.removeTween(tm);
                        return;
                    }
                },
                onComplete:function ():void{
                    sceneChar.moveData.clear();
                    if ($isPetJump){
                        if (hasSolid){
                            sceneChar.visible = true;
                        };
                        sceneChar.playTo(CharStatusType.STAND);
                    }
                    sceneChar.setXY(p1.x, p1.y);
                    if (((!((vars == null))) && (!((vars.onLineArrived == null))))){
                        vars.onLineArrived(sceneChar, mapTile);
                    }
                }
            });
        }
		
        public static function lineToPixel(p_char:CCCharacter, p_pos:Point, p_speed:Number, callback:Function=null):void {
            var p1:Point = null;
            var tm:* = null;
            var sceneChar:CCCharacter = p_char;
            var pixelPos:Point = p_pos;
            var speed:Number = p_speed;
            var onComplete:Function = callback;
            sceneChar.moveData.clear();
            if (speed == 0){
                return;
            }
            var p0:Point = new Point(sceneChar.PixelX, sceneChar.PixelY);
            p1 = new Point(pixelPos.x, pixelPos.y);
            var distance:* = Point.distance(p0, p1);
            sceneChar.moveData.isJumping = true;
            sceneChar.specilizeX = sceneChar.PixelX;
            sceneChar.specilizeY = sceneChar.PixelY;
            var time:* = (distance / speed);
            tm = TweenMax.to(sceneChar, time, {
                PixelX:p1.x,
                PixelY:p1.y,
                specilizeX:p1.x,
                specilizeY:p1.y,
                ease:Expo.easeOut,
                onUpdate:function ():void{
                    if (sceneChar.usable == false){
//                        TweenMax.removeTween(tm);
                        return;
                    }
                },
                onComplete:function ():void{
                    sceneChar.moveData.clear();
                    sceneChar.setXY(p1.x, p1.y);
                    if (onComplete != null){
                        HandlerHelper.execute(onComplete);
                    }
                }
            });
        }
    }
}