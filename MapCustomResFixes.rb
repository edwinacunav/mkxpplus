# Increased MKXPPlus Resolution Map Fix
# * Scripter : Kyonides-Arkanthes
#  2018-10-31

class Game_Map
  def scroll_down(distance)
    tiles_max = Graphics.height / 32
    @display_y = [@display_y + distance, (self.height - tiles_max) * 128].min
  end

  def scroll_right(distance)
    tiles_max = Graphics.width / 32
    @display_x = [@display_x + distance, (self.width - tiles_max) * 128].min
  end
end

class Game_Player < Game_Character
  def center_x() (Graphics.width / 2 - 16) * 4  end
  def center_y() (Graphics.height / 2 - 16) * 4 end
  def center(x, y)
    max_x = ($game_map.width - Graphics.width / 32) * 128
    max_y = ($game_map.height - Graphics.height / 32) * 128
    $game_map.display_x = [0, [x * 128 - center_x, max_x].min].max
    $game_map.display_y = [0, [y * 128 - center_y, max_y].min].max
  end

  def update
    last_moving = moving?
    unless moving? or $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing
      # Move player in the direction the directional button is being pressed
      case Input.dir4
      when 2
        move_down
      when 4
        move_left
      when 6
        move_right
      when 8
        move_up
      end
    end
    last_real_x = @real_x
    last_real_y = @real_y
    super
    if @real_y > last_real_y and @real_y - $game_map.display_y > center_y
      $game_map.scroll_down(@real_y - last_real_y)
    end
    if @real_x < last_real_x and @real_x - $game_map.display_x < center_x
      $game_map.scroll_left(last_real_x - @real_x)
    end
    if @real_x > last_real_x and @real_x - $game_map.display_x > center_x
      $game_map.scroll_right(@real_x - last_real_x)
    end
    if @real_y < last_real_y and @real_y - $game_map.display_y < center_y
      $game_map.scroll_up(last_real_y - @real_y)
    end
    unless moving?
      if last_moving
        result = check_event_trigger_here([1,2])
        if result == false
          unless $DEBUG and Input.press?(Input::CTRL)
            if @encounter_count > 0
              @encounter_count -= 1
            end
          end
        end
      end
      if Input.trigger?(Input::C)
        check_event_trigger_here([0])
        check_event_trigger_there([0,1,2])
      end
    end
  end
end

class Spriteset_Map
  def initialize
    w = Graphics.width
    h = Graphics.height
    @viewport1 = Viewport.new(0, 0, w, h)
    @viewport2 = Viewport.new(0, 0, w, h)
    @viewport3 = Viewport.new(0, 0, w, h)
    @viewport2.z = 200
    @viewport3.z = 5000
    @tilemap = Tilemap.new(@viewport1)
    @tilemap.tileset = RPG::Cache.tileset($game_map.tileset_name)
    for i in 0..6
      autotile_name = $game_map.autotile_names[i]
      @tilemap.autotiles[i] = RPG::Cache.autotile(autotile_name)
    end
    @tilemap.map_data = $game_map.data
    @tilemap.priorities = $game_map.priorities
    @tilemap.ox = $game_map.display_x / 4
    @tilemap.oy = $game_map.display_y / 4
    @tilemap.update
    @panorama = Plane.new(@viewport1)
    @panorama.z = -1000
    @fog = Plane.new(@viewport1)
    @fog.z = 3000
    @character_sprites = []
    for i in $game_map.events.keys.sort
      sprite = Sprite_Character.new(@viewport1, $game_map.events[i])
      @character_sprites.push(sprite)
    end
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
    @weather = RPG::Weather.new(@viewport1)
    @picture_sprites = []
    for i in 1..50
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_screen.pictures[i]))
    end
    @timer_sprite = Sprite_Timer.new
    update
  end
end