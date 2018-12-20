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
    public class StreamPc : Gtk.Button {
        static StreamPc _instance = null;
        public static StreamPc instance {
            get {
                if (_instance == null)
                    _instance = new StreamPc ();
                return _instance;
            }
        }

        public bool stream_active {get; set;}
        public signal void signal_stream ();
        public Button stream_button;
        private Image icon_pc;
        private Image icon_stream;

        public StreamPc () {}

        construct {
            icon_pc = new Gtk.Image.from_icon_name ("computer-symbolic", Gtk.IconSize.BUTTON);
            icon_stream = new Gtk.Image.from_icon_name ("internet-web-browser-symbolic", Gtk.IconSize.BUTTON);

            stream_button = new Button ();
            var converter = new ObjectConverter ();
            stream_button.clicked.connect (() => {
                if (!converter.is_running) {
                    signal_stream ();
                    if (stream_active) {
                        stream_button.tooltip_text = _("PC");
                        stream_button.set_image (icon_pc);
                        stream_active = false;
                        MindiApp.settings.set_boolean ("stream-mode", false);
                    } else {
                        stream_button.tooltip_text = _("Stream");
                        stream_button.set_image (icon_stream);
                        stream_active = true;
                        MindiApp.settings.set_boolean ("stream-mode", true);
                    }
                }
            });
            if (MindiApp.settings.get_boolean ("stream-mode")) {
                stream_button.tooltip_text = _("Stream");
                stream_button.set_image (icon_stream);
                stream_active = true;
            } else {
                stream_button.tooltip_text = _("PC");
                stream_button.set_image (icon_pc);
                stream_active = false;
            }
        }
    }
}
