package trivia {

	import flash.errors.*;
	import flash.events.*;
	import flash.net.Socket;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.system.*;

	public class CustomSocket extends Socket {
		
		private var response:String;
		private var timeline:Object;
		private var answers:Array;

		public function CustomSocket(_ref:Object, host:String = null, port:uint = 0) {
			super();
			configureListeners();
			if (host && port)  {
				response = "";
				this.timeline = _ref;
				super.connect(host, port);
			}
		}

		public function getAnswers():Array {
			return answers;
		}

		private function configureListeners():void {
			addEventListener(Event.CLOSE, closeHandler);
			addEventListener(Event.CONNECT, connectHandler);
			addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		}

		public function writeln(str:String):void {
			str += "\n";
			try {
				trace("Sending: " + str);
				writeUTFBytes(str);
			}
			catch(e:IOError) {
				trace(e);
			}
		}

		private function sendRequest():void {
			trace("sendRequest");
			response = "";
			writeln("JOIN JT WAIT");
			flush();
		}

		private function readResponse():void {
			var str:String = readUTFBytes(bytesAvailable);
			response += str;
			//timeline.chatGlobalBox.text += response+"\n";
			var index:int = response.indexOf("\n");
			//trace("response = "+response);
			//trace("index = "+index);
			if(index != -1){
				var cmd:String = response.substr(0, index);
				response = response.substr(index+1);
				processCommand(cmd);
			}
		}
		
		// When a command is received send here to be processed
		public function processCommand(cmd:String):void {
		    trace("Received Command: " + cmd);
			var arr:Array = cmd.split (' ');
			var j:int;
			var userID:String;
			var msg:String
			if(arr[0] == "TIME") {
				timeline.timerBox.text = arr[1];
			}
			else if(arr[0] == "MESSAGE"){
				j = 2;
				userID = arr[1].substring(1);
				while(arr[j].toString().indexOf("#") == -1){
					userID = userID + " " + arr[j];
					j++;
				}
				msg = arr[j].toString().substring(1);
				for(j++; j < arr.length; j++){
					msg = msg + " " + arr[j];
				}
				timeline.chatBox.text += userID + ": " + msg + "\n";
			}
			else if(arr[0] == "GMESSAGE"){
				j = 2;
				userID = arr[1].substring(1);
				while(arr[j].toString().indexOf("#") == -1){
					userID = userID + " " + arr[j];
					j++;
				}
				msg= arr[j].toString().substring(1);
				for(j++; j < arr.length; j++){
					msg = msg + " " + arr[j];
				}
				timeline.chatGlobalBox.text += userID + ": " + msg + "\n";
			}
			else if(arr[0] == "END"){
				this.close();
			}
			else if(arr[0] == "CORRECT") {
				
			}
			else if(arr[0] == "Wrong") {
				
			}
			else if(arr[0] == "START") {
				var question:String = "";
				var qCount:int = 0;
				var a1:String = "";
				var a2:String = "";
				var a3:String = "";
				var questionID:String = arr[2];
				var gameID:String = arr[1];
				timeline.enableButtons();
				
				for(var m:int = 0; m < arr.length; m++) {
					trace(arr[m]);
				}
				
				for(var i:int = 3; i < arr.length; i++) {
					if(arr[i].toString().indexOf("#") > -1) {
						a1 = a1 + (arr[i].toString()).substring(1);
						i++;
						while(arr[i].toString().indexOf("#") == -1) {
							a1 = a1 + " " + arr[i].toString();
							i++;
						}
						trace("a1 = " + a1);
						a2 = a2 + (arr[i].toString()).substring(1);
						i++;
						while(arr[i].toString().indexOf("#") == -1) {
							a2 = a2 + " " + arr[i].toString();
							i++;
						}
						trace("a2 = " + a2);
						a3 = a3 + (arr[i].toString()).substring(1);
						i++;
						while(arr[i] != null && arr[i].toString().indexOf("#") == -1) {
							a3 = a3 + " " + arr[i].toString();
							i++;
						}
						trace("a3 = " + a3);
						break;
					}
					else {
						question = question + " " + arr[i];
					}
				}
				
				// Randomize by swapping two answers
				var myRandomList:Array = new Array(a1, a2, a3, gameID, questionID);
				answers = new Array(a1, a2, a3, gameID, questionID);
				var a:int = Math.floor(Math.random() * 3);
				var b:int = Math.floor(Math.random() * 3);
				var temp:String = myRandomList[a];
				myRandomList[a] = myRandomList[b];
				myRandomList[b] = temp;
				
				timeline.questionBox.text = question;
				timeline.answer1.label = myRandomList[0];
				timeline.answer2.label = myRandomList[1];
				timeline.answer3.label = myRandomList[2];
			}
		}

		private function closeHandler(event:Event):void {
			trace("closeHandler: " + event);
			trace(response.toString());
		}

		private function connectHandler(event:Event):void {
			trace("connectHandler: " + event);
			timeline.chatGlobalBox.text += "Connected\n";
			sendRequest();
		}

		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
			timeline.chatGlobalBox.text += "IO Error\n";
		}

		private function securityErrorHandler(event:SecurityErrorEvent):void {
			trace("securityErrorHandler: " + event);
			timeline.chatGlobalBox.text += "Security Error\n";
		}

		private function socketDataHandler(event:ProgressEvent):void {
			//trace("socketDataHandler: " + event);
			//timeline.chatGlobalBox.text += "Got Data...\n";
			readResponse();
		}
	}
}