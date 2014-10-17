Pod::Spec.new do |s|

  s.name         = "KWKeyboardListener"
  s.version      = "1.0"
  s.summary      = "Easy way to make a class react to keyboard events."

  s.description  = <<-DESC
		   Make your classes listen to and react to Keyboard events in one line of code.
			Supported events are:
			* Will Show
			* Did Show
			* Will Change Frame
			* Did Change Frame
			* Will Hide
			* Did Hide
			
			Just use the class's add/removeListener methods and implement the events you wish to support.
                   DESC

  s.homepage     = "https://github.com/Altimor/KWKeyboardListener"

  s.license      = "GPL-3"


  s.author             = { "Florent Crivello" => "florent.crivello@gmail.com" }
  s.platform     = :ios, "5.0"

  s.source       = { :git => "https://github.com/Altimor/KWKeyboardListener", :tag => "1.0" }
  s.source_files  = "KeyboardListener/KWKeyboardListener", "KeyboardListener/KWKeyboardListener/*.{h,m}"

end
