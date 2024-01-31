from libqtile import widget
from .theme import colors
import netifaces

# Get the icons at https://www.nerdfonts.com/cheat-sheet (you need a Nerd Font)

def base(fg='text', bg='dark'): 
    return {
        'foreground': colors[fg],
        'background': colors[bg]
    }

def separator():
    return widget.Sep(**base(), linewidth=0, padding=5)

def icon(fg='text', bg='dark', fontsize=16, text="?"):
    return widget.TextBox(
        **base(fg, bg),
        fontsize=fontsize,
        text=text,
        padding=3
    )

def powerline(fg="light", bg="dark"):
    return widget.TextBox(
        **base(fg, bg),
        text="", # Icon: nf-ple-flame_thick_mirrored
        fontsize=37,
        padding=-2
    )

def workspaces(): 
    return [
        separator(),
        widget.GroupBox(
            **base(fg='light'),
            font='HackNerdFonts',
            fontsize=19,
            margin_y=3,
            margin_x=0,
            padding_y=8,
            padding_x=5,
            borderwidth=1,
            active=colors['active'],
            inactive=colors['inactive'],
            rounded=False,
            highlight_method='block',
            urgent_alert_method='block',
            urgent_border=colors['urgent'],
            this_current_screen_border=colors['focus'],
            this_screen_border=colors['grey'],
            other_current_screen_border=colors['dark'],
            other_screen_border=colors['dark'],
            disable_drag=True
        ),
        separator(),
        widget.WindowName(**base(fg='focus'), fontsize=14, padding=5),
        separator(),
    ]

def interface_HTB(interface='tun0', **kwargs):
    inactive_text = '0.0.0.0'
    try:
        ip_info = netifaces.ifaddresses(interface).get(netifaces.AF_INET, [])
        ip = ip_info[0]['addr'] if ip_info else ''
    except:
        ip=''
    text = ip if ip else inactive_text
    return widget.TextBox(
            text=text,
            **kwargs
            )

primary_widgets = [
    *workspaces(),

    separator(),

    powerline('color4', 'dark'),

    icon(bg='color4', text='  '), # Icon: nf-fa-download
    
    widget.CheckUpdates(
        background=colors['color4'],
        colour_have_updates=colors['text'],
        colour_no_updates=colors['text'],
        no_update_string='0',
        display_format='{updates}',
        update_interval=1800,
        custom_command='checkupdates',
    ),

    powerline('color3', 'color4'),

    icon(bg='color3', text=' 󰩠 '),  # Icon: nf-md-ip_network
    
    widget.Net(**base(bg='color3'), interface='enp0s3'),

    powerline('color2', 'color3'),

    icon(bg='color2', text=' 󰆧 '), #Icon: nf-md-cube_outline

    interface_HTB(**base(bg='color2')),
  
    powerline('color1', 'color2'),
 
    icon(bg='color1', text='  '), #Icon: nf-fa-crosshairs

    
  
    powerline('dark', 'color1'),
    
    widget.CurrentLayout(padding=5),

    widget.CurrentLayoutIcon(scale=0.65),

    widget.Systray(background=colors['dark'], padding=5),
]

secondary_widgets = [
    *workspaces(),

    separator(),

    powerline('color1', 'dark'),

    widget.CurrentLayoutIcon(**base(bg='color1'), scale=0.65),

    widget.CurrentLayout(**base(bg='color1'), padding=5),

    powerline('color2', 'color1'),

    widget.Clock(**base(bg='color2'), format='%d/%m/%Y - %H:%M '),

    powerline('dark', 'color2'),
]

widget_defaults = {
    'font': 'HackNerdFonts',
    'fontsize': 14,
    'padding': 1,
}
extension_defaults = widget_defaults.copy()
