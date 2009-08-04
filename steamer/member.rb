#
#  member.rb
#  
#
#  Created by Jordan Byron on 8/3/09.
#  Copyright (c) 2009 Duck Soup Software. All rights reserved.
#
module Steamer

class Member
  attr_accessor :id, :name
  
  def initialize(steam_id,name="Unknown")
    @id, @name = steam_id, name
    @url = "http://steamcommunity.com/profiles/#{steam_id}"
  end
  
  def status
    doc = Hpricot(open(@url))
    
    @name = doc.search("title").text.match(/\ASteam Community :: ID :: (\S+)/).captures
    
    in_game = (doc/"#statusInGameText").inner_html.strip
    
    if in_game.length == 0
      in_game = "Not in game" 
    else
      in_game = "Playing #{in_game}"
    end
    
    return in_game
  end
  
  def watch_user_status(interval = 30)
    last_status = ""
    catch(:stop_listening) do
      trap('INT') { throw :stop_listening }
      loop do
        new_status = status
        if last_status != new_status and new_status[/: Playing/]
          yield new_status
        end
        last_status = new_status
        sleep interval
      end
    end
  end
  
  def friends
    friends = Array.new
    doc = Hpricot(open(@url + "/friends"))
    
    (doc/'a[@class^="linkFriend_"]').each do |friend|
      friend_id = friend[:href].match(/http:\/\/steamcommunity.com\/profiles\/(\S+)/).captures[0] if friend[:href].match(/http:\/\/steamcommunity.com\/profiles\/(\S+)/)
      friends << Member.new(friend_id,friend.inner_html) if friend_id
    end
    
    return friends
  end
end

end