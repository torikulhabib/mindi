/*-
 * Copyright (c) 2016-2017 elementary LLC. (https://elementary.io)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the Lesser GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Artem Anufrij <artem.anufrij@live.de>
 *              Daniel Foré <daniel@elementary.io>
 *              Daniel Foré <torik.habib@gmail.com>
 *
 */

namespace Mindi.Widgets {
    public class Toast : Gtk.Revealer {
        public signal void default_action ();
        private Gtk.Label notification_label;
        private uint hiding_timer = 0;

        private string _title;
        public string title {
            get {
                return _title;
            }
            construct set {
                if (notification_label != null) {
                    notification_label.label = value;
                }
                _title = value;
            }
        }

        public Toast (string title) {
            Object (title: title);
        }

        construct {
            margin = 3;
            halign = Gtk.Align.CENTER;
            valign = Gtk.Align.START;
            notification_label = new Gtk.Label (title);
            notification_label.ellipsize = Pango.EllipsizeMode.END;
            notification_label.max_width_chars = 42;

            var notification_box = new Gtk.Grid ();
            notification_box.column_spacing = 12;
            notification_box.add (notification_label);

            var notification_frame = new Gtk.Frame (null);
            notification_frame.get_style_context ().add_class ("app-notification");
            notification_frame.add (notification_box);
            add (notification_frame);
        }

        public void send_notification () {
            reveal_child = true;
            if (hiding_timer != 0) {
                Source.remove (hiding_timer);
            }
            hiding_timer = GLib.Timeout.add (4500, () => {
                reveal_child = false;
                hiding_timer = 0;
                return false;
            });
        }
    }
}
