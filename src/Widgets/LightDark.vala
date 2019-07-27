/*
* Copyright (C) 2018  Torikul habib <torik.habib@gmail.com>
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: torikulhabib <torik.habib@gmail.com>
*/

using Gtk;
namespace Mindi {
    public class LightDark : Gtk.Button {
        static LightDark _instance = null;
        public static LightDark instance {
            get {
                if (_instance == null)
                    _instance = new LightDark ();
                return _instance;
            }
        }
        private bool background_active {get; set;}
        public Button light_dark_button;
        private Image icon_light;
        private Image icon_dark;

        public LightDark () {}

        construct {
            icon_light = new Gtk.Image.from_icon_name ("display-brightness-symbolic", Gtk.IconSize.BUTTON);
            icon_dark = new Gtk.Image.from_icon_name ("weather-clear-night-symbolic", Gtk.IconSize.BUTTON);

            light_dark_button = new Button ();
            light_dark_button.clicked.connect (() => {
                if (background_active) {
                    light_dark_button.tooltip_text = Mindi.StringPot.Light;
                    light_dark_button.set_image (icon_light);
                    background_active = false;
                    Gtk.Settings.get_default().gtk_application_prefer_dark_theme = false;
                    MindiApp.settings.set_boolean ("dark-light", false);
                } else {
                    light_dark_button.tooltip_text = Mindi.StringPot.Dark;
                    light_dark_button.set_image (icon_dark);
                    background_active = true;
                    Gtk.Settings.get_default().gtk_application_prefer_dark_theme = true;
                    MindiApp.settings.set_boolean ("dark-light", true);
                }
            });
            if (MindiApp.settings.get_boolean ("dark-light")) {
                Gtk.Settings.get_default().gtk_application_prefer_dark_theme = true;
                light_dark_button.set_image (icon_dark);
                light_dark_button.tooltip_text = Mindi.StringPot.Dark;
                background_active = true;
            } else {
                Gtk.Settings.get_default().gtk_application_prefer_dark_theme = false;
                light_dark_button.set_image (icon_light);
                light_dark_button.tooltip_text = Mindi.StringPot.Light;
                background_active = false;
            }
        }
    }
}
