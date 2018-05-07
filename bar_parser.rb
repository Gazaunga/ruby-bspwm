#!/usr/bin/env ruby

require 'json'

# ---- Config Variables ----
# Path to JSON formatted colour list ( #{Dir.home} represents ~ )
$color_file = "#{Dir.home}/.Xresources.d/bar-colors.json"

# ---- File Preparation ----
$c = File.open($color_file, "r+")
$colors = JSON.parse($c.read, symbolize_names: true)
$c.close
# Flush stdout immediately
STDOUT.sync = true

# ---- Functions ----
def colorWrapper(fg, bg, data, params={})
  # Wrap data in lemonbar markup, with optional clickable element
  puts "oops"+params[:click] if fg.nil? || bg.nil?
  if !params[:click]
    "%{F#{fg}}%{B#{bg}} #{data} %{B-}%{F-}"
  else
    "%{F#{fg}}%{B#{bg}}%{A:#{params[:click]}:} #{data} %{A}%{B-}%{F-}"
  end
end


# ---- Main ----
# Get number of monitors and initialize an array to hold their properties
$numMonitors = `bspc query -M`.lines.count
$wm_array = Array.new($numMonitors)

# Loop over STDIN
while line = gets
  data = line[1..-1].chomp
  case line
  when /^N/
    # Network information
    net = colorWrapper($colors[:SYS_FG], $colours[:SYS_BG], data, click:'urxvt -e "nmtui"')
  when /^B/
    # Battery Information
    batt = colorWrapper($colors[:SYS_FG], $colours[:SYS_BG], data)
  when /^V/
    # Volume Information
    vol = colorWrapper($colors[:SYS_FG], $colours[:SYS_BG], data)
  when /^S/
    # Clock Information
    sys = colorWrapper($colors[:SYS_FG], $colours[:SYS_BG], data, click:'notify-send "`cal`"')
  when /^T/
    # Window Title Information
    title = colorWrapper($colors[:SYS_FG], $colours[:SYS_BG], data)
  when /^W/
    # Bspwm State Information
    wm=""
    cur_mon=-1
    desktop_num=0
    data.split(":").each do |item|
      name = item[1..-1].chomp
      case item
      when /^[mM]/
        if $numMonitors < 2
          next
        end
        case item
        when /^m/
          # Inactive monitor
          cur_mon+=1
          wm=""
          fg=$colors[:MONITOR_FG]
          bg=$colors[:MONITOR_BG]
        when /^M/
          # Active monitor
          cur_mon+=1
          wm=""
          fg=$colors[:FOCUSED_MONITOR_FG]
          bg=$colors[:FOCUSED_MONITOR_BG]
        end
        wm = wm << colorWrapper(fg,bg,name,click:"bspc monitor -f #{name}")
      when /^[fFoOuU]/
        case item
        when /^f/
          # Free desktop
          fg=$colors[:FREE_FG]
          bg=$colors[:FREE_BG]
          desktop_num+=1
        when /^F/
          # Focused free desktop
          fg=$colors[:FOCUSED_FREE_FG]
          bg=$colors[:FOCUSED_FREE_BG]
          desktop_num+=1
        when /^o/
          # occupied desktop
          fg=$colors[:OCCUPIED_FG]
          bg=$colors[:OCCUPIED_BG]
          desktop_num+=1
        when /^O/
          # Focused occupied desktop
          fg=$colors[:FOCUSED_OCCUPIED_FG]
          bg=$colors[:FOCUSED_OCCUPIED_BG]
          desktop_num+=1
        when /^u/
          # urgent desktop
          fg=$colors[:URGENT_FG]
          bg=$colors[:URGENT_BG]
          desktop_num+=1
        when /^U/
          # Focused urgent desktop
          fg=$colors[:FOCUSED_URGENT_FG]
          bg=$colors[:FOCUSED_URGENT_BG]
          desktop_num+=1
        end
        wm = wm << colorWrapper(fg,bg,name,click:"bspc desktop -f ^#{desktop_num}")
      when /^[LTG]/
        # Layout, State, and Flags
        wm = wm << colorWrapper($colours[:STATE_FG],$colours[:STATE_BG],name)
      end
      $wm_array[cur_mon]=wm
    end	
  end

  if $numMonitors > 1
    print "%{l}#{$wm_array[0]}%{c}#{title}%{r}#{net} | #{batt} | #{vol} | #{sys}"
    print "%{S+}%{l}#{$wm_array[1]}%{c}#{title}%{r}#{net} | #{batt} | #{vol} |  #{sys}\n"
  else
    print "%{l}#{$wm_array[0]}%{c}#{title}%{r}#{net} | #{batt} | #{vol} | #{sys}\n"
  end

end

