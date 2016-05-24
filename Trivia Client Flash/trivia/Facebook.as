package trivia {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public class Facebook extends Sprite
	{
		private var theStage:Object;
		public function Facebook(theStage:Object)
		{	
			this.theStage = theStage;
			init();
		}
		
		private function init():void{
			ExternalInterface.addCallback("myFlashcall",myFlashcall);
			theStage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function myFlashcall(str:String):void
		{
			trace("myFlashcall: "+str);
		}
		
		protected function onClick(event:MouseEvent):void
		{
			if(ExternalInterface.available){
				trace("onClick");
				ExternalInterface.call("myFBcall");
			}
		}
	}

}