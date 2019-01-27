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
    public class Dialog : Gtk.Dialog {
        public ComboBoxText warning;
        public signal void dialog_cancel_convert ();
        public Dialog (Gtk.Window? parent) {
            Object (
                border_width: 0,
                deletable: false,
                resizable: false,
                title: _("Warning"),
                transient_for: parent,
                destroy_with_parent: true,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT
            );
        }

        construct {
            var header = new Granite.HeaderLabel (_("Are you sure want to cancel this process?"));
            var warning = new Granite.Widgets.ModeButton ();
            warning.append_text (_("No"));
            warning.append_text (_("Yes"));

            warning.mode_changed.connect (() => {
                switch (warning.selected) {
                    case 0:
                        destroy ();
                        break;
                    case 1:
                        dialog_cancel_convert ();
                        destroy ();
                        break;
                }
            });

            var main_grid = new Gtk.Grid ();
            main_grid.margin_top = 0;
            main_grid.column_spacing = 12;
            main_grid.column_homogeneous = true;
            main_grid.attach (header, 0, 0, 1, 1);
            main_grid.attach (warning, 0, 1, 1, 1);

            get_content_area ().margin = 6;

            var content = this.get_content_area () as Gtk.Box;
            content.margin = 6;
            content.margin_top = 0;
            content.add (main_grid);
            button_press_event.connect ((e) => {
                if (e.button == Gdk.BUTTON_PRIMARY) {
                    begin_move_drag ((int) e.button, (int) e.x_root, (int) e.y_root, e.time);
                    return true;
                }
                return false;
            });
        }
    }
}
