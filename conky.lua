clock_x = 156
clock_y = 245
clock_r = 78
show_seconds = true

settings_table = {
  {
      name='memperc',
      arg='',
      max=100,
      bg_colour=0xffffff,
      bg_alpha=0.1,
      fg_colour=0xFF6600,
      fg_alpha=0.8,
      x=156, y=245,
      radius=110,
      thickness=10,
      start_angle=43,
      end_angle=180
  },
  {
      name='cpu',
      arg='cpu0',
      max=100,
      bg_colour=0xffffff,
      bg_alpha=0.1,
      fg_colour=0xFF6600,
      fg_alpha=0.8,
      x=156, y=245,
      radius=127,
      thickness=4,
      start_angle=-90,
      end_angle=42
  },
  {
      name='cpu',
      arg='cpu1',
      max=100,
      bg_colour=0xffffff,
      bg_alpha=0.1,
      fg_colour=0xFF6600,
      fg_alpha=0.8,
      x=156, y=245,
      radius=120,
      thickness=4,
      start_angle=-90,
      end_angle=42
  },
  {
      name='cpu',
      arg='cpu2',
      max=100,
      bg_colour=0xffffff,
      bg_alpha=0.1,
      fg_colour=0xFF6600,
      fg_alpha=0.8,
      x=156, y=245,
      radius=113,
      thickness=4,
      start_angle=-90,
      end_angle=42
  },
  {
      name='cpu',
      arg='cpu3',
      max=100,
      bg_colour=0xffffff,
      bg_alpha=0.1,
      fg_colour=0xFF6600,
      fg_alpha=0.8,
      x=156, y=245,
      radius=106,
      thickness=4,
      start_angle=-90,
      end_angle=42
  },
  {
      name='freq',
      arg='',
      max=3200,
      bg_colour=0xffffff,
      bg_alpha=0.1,
      fg_colour=0xFF6600,
      fg_alpha=0.8,
      x=156, y=245,
      radius=124,
      thickness=10,
      start_angle=43,
      end_angle=180
  }
}


require 'cairo'

function rgb_to_r_g_b(colour,alpha)
    return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end


function draw_ring(cr,t,pt)
    local w,h=conky_window.width,conky_window.height

    local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
    local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']


    local angle_0=sa*(2*math.pi/360)-math.pi/2
    local angle_f=ea*(2*math.pi/360)-math.pi/2
    local t_arc=t*(angle_f-angle_0)


    -- Draw background ring


    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
    cairo_set_line_width(cr,ring_w)
    cairo_stroke(cr)

    -- Draw indicator ring


    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
    cairo_stroke(cr)
end


function draw_clock_hands(cr,xc,yc)
    local secs,mins,hours,secs_arc,mins_arc,hours_arc
    local xh,yh,xm,ym,xs,ys

    secs=os.date("%S")
    mins=os.date("%M")
    hours=os.date("%I")

    secs_arc=(2*math.pi/60)*secs
    mins_arc=(2*math.pi/60)*mins+secs_arc/60
    hours_arc=(2*math.pi/12)*hours+mins_arc/12

    -- Draw hour hand

    xh=xc+0.7*clock_r*math.sin(hours_arc)
    yh=yc-0.7*clock_r*math.cos(hours_arc)
    cairo_move_to(cr,xc,yc)
    cairo_line_to(cr,xh,yh)

    cairo_set_line_cap(cr,CAIRO_LINE_CAP_ROUND)
    cairo_set_line_width(cr,7)
    cairo_set_source_rgba(cr,1.0,1.0,1.0,1.0)
    cairo_stroke(cr)

    -- Draw minute hand

    xm=xc+clock_r*math.sin(mins_arc)
    ym=yc-clock_r*math.cos(mins_arc)
    cairo_move_to(cr,xc,yc)
    cairo_line_to(cr,xm,ym)

    cairo_set_line_width(cr,5)
    cairo_stroke(cr)

    -- Draw seconds hand

    if show_seconds then
        xs=xc+clock_r*math.sin(secs_arc)
        ys=yc-clock_r*math.cos(secs_arc)
        cairo_move_to(cr,xc,yc)
        cairo_line_to(cr,xs,ys)

        cairo_set_line_width(cr,2)
        cairo_stroke(cr)
    end
end

function conky_main()
 local function setup_rings(cr,pt)
     local str=''
     local value=0

     str=string.format('${%s %s}',pt['name'],pt['arg'])
     str=conky_parse(str)

     value=tonumber(str)
     pct=str/pt['max']

     draw_ring(cr,pct,pt)
 end

    if conky_window == nil then
        return
    end
    local cs = cairo_xlib_surface_create(conky_window.display,
                                         conky_window.drawable,
                                         conky_window.visual,
                                         conky_window.width,
                                         conky_window.height)
    local cr = cairo_create(cs)
    local updates=tonumber(conky_parse('${updates}'))
    if updates>5 then
      for i in pairs(settings_table) do
         setup_rings(cr,settings_table[i])
      end
    end
    draw_clock_hands(cr,clock_x,clock_y)
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    cr=nil
end
