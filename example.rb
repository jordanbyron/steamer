require 'steamer'

class example

  
  def start
    test_steamer = Steamer.new "76561197992872668"
    
    test_steamer.watch_user_status do |message|
      puts message
    end
  end

end