require 'rubygems'
require 'open-uri'
require 'net/http'
require 'hpricot'

class Steamer
  
  def initialize steam_id
    @steam_id = steam_id
    @url = "http://steamcommunity.com/profiles/#{steam_id}"
  end
  
  def check_status
    doc = Hpricot(open(@url))
    
    steam_name = doc.search("title").text.match(/\ASteam Community :: ID :: (\S+)/).captures
    
    in_game = (doc/"#statusInGameText").inner_html.strip
    
    if in_game.length == 0
      in_game = "Not in game" 
    else
      in_game = "Playing #{in_game}"
    end
    
    return "#{steam_name}: #{in_game}"
  end
  
  def watch_user_status(interval = 30)
    last_status = ""
    catch(:stop_listening) do
      trap('INT') { throw :stop_listening }
      loop do
        new_status = check_status
        if last_status != new_status and new_status[/: Playing/]
          yield new_status
        end
        last_status = new_status
        sleep interval
      end
    end
  end
end
