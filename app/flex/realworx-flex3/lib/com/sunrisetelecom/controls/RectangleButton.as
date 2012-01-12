package com.sunrisetelecom.controls
{
    import flash.display.*
    import flash.text.*;
    import flash.filters.DropShadowFilter;

    public class RectangleButton extends SimpleButton
    {
        // The text to appear on the button
        private var _text:String;
        // Save the width and height of the rectangle
        private var _width:Number;
        private var _height:Number;
    
        public function RectangleButton( text:String, width:Number, height:Number )
        {
            // Save the values to use them to create the button states
            _text = text;
            _width = width;
            _height = height;
      
            // Create the button states based on width, height, and text value
            upState = createUpState();
            overState = createOverState();
            downState = createDownState();
            hitTestState = upState;
        }
  
        // Create the display object for the button's up state
        private function createUpState():Sprite
        {
            var sprite:Sprite = new Sprite();
      
            var background:Shape = createdColoredRectangle(0x33FF66);
            var textField:TextField = createTextField(false);
          
            sprite.addChild(background);
            sprite.addChild(textField);

            return sprite;
        }
    
        // Create the display object for the button's up state
        private function createOverState():Sprite
        {
            var sprite:Sprite = new Sprite();
      
            var background:Shape = createdColoredRectangle( 0x70FF94 );
            var textField:TextField = createTextField( false );
            
            sprite.addChild( background );
            sprite.addChild( textField );

            return sprite;
        }
    
        // Create the display object for the button's down state
        private function createDownState():Sprite
        {
            var sprite:Sprite = new Sprite();
      
            var background:Shape = createdColoredRectangle( 0xCCCCCC );
            var textField:TextField = createTextField( true );
      
            sprite.addChild( background );
            sprite.addChild( textField );
      
            return sprite;
        }
    
        // Create a rounded rectangle with a specific fill color
        private function createdColoredRectangle(color:uint):Shape
        {
            var rect:Shape = new Shape();
            rect.graphics.lineStyle(1, 0x000000);
            rect.graphics.beginFill(color);
            rect.graphics.drawRoundRect(0, 0, _width, _height, 15);
            rect.graphics.endFill();
            rect.filters = [new DropShadowFilter( 2 )];
            return rect;
        }
    
        // Create the text field to display the text of the button
        private function createTextField( downState:Boolean ):TextField
        {
            var textField:TextField = new TextField();
            textField.text = _text;
            textField.width = _width;
            
            // Center the text horizontally
            var format:TextFormat = new TextFormat();
            format.align = TextFormatAlign.CENTER;
            textField.setTextFormat( format );
      
            // Center the text vertically
            textField.y = (_height - textField.textHeight) / 2;
            textField.y -= 2;  // Subtract 2 pixels to adjust for offset
      
            // The down state places the text down and to the right
            // further than the other states
            if (downState)
            {
                textField.x += 1;
                textField.y += 1;
            }
            return textField;
        }
    }
}
