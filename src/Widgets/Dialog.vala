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

namespace Mindi {
    public class Dialog : Granite.MessageDialog {
        public signal void dialog_cancel_convert ();

        public Dialog (Gtk.Window? parent) {
            Object (
                image_icon: new ThemedIcon ("dialog-warning"),
                primary_text: _("Are you sure want to quit this process?"),
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
            add_button (_("Cancel"), Gtk.ButtonsType.CANCEL);

            var quit_button = new Gtk.Button.with_label (_("Quit"));
            quit_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            add_action_widget (quit_button, Gtk.ResponseType.YES);

            response.connect ((response_id) => {
                if (response_id == Gtk.ResponseType.YES) {
                    dialog_cancel_convert ();
                }

                destroy ();
            });
        }
    }
}
