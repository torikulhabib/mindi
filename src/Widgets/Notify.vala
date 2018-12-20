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
    public class NotifySilent : Gtk.Button {
        static NotifySilent _instance = null;
        public static NotifySilent instance {
            get {
                if (_instance == null)
                    _instance = new NotifySilent ();
                return _instance;
            }
        }
        public bool notify_active {get; set;}
        public Button notify_button;
        private Image icon_notify;
        private Image icon_silent;

        public NotifySilent () {}

        construct {
            icon_notify = new Gtk.Image.from_icon_name ("notification-symbolic", Gtk.IconSize.BUTTON);
            icon_silent = new Gtk.Image.from_icon_name ("notification-disabled-symbolic", Gtk.IconSize.BUTTON);

            notify_button = new Gtk.Button ();
            notify_button.clicked.connect (() => {
                if (notify_active) {
                    notify_button.tooltip_text = _("Silent");
                    notify_button.set_image (icon_silent);
                    notify_active = false;
                    MindiApp.settings.set_boolean ("notify-silent", false);
                } else {
                    notify_button.tooltip_text = _("Notify");
                    notify_button.set_image (icon_notify);
                    notify_active = true;
                    MindiApp.settings.set_boolean ("notify-silent", true);
                }
            });
            if (MindiApp.settings.get_boolean ("notify-silent")) {
                notify_button.tooltip_text = _("Notify");
                notify_button.set_image (icon_notify);
                notify_active = true;
            } else {
                notify_button.set_image (icon_silent);
                notify_button.tooltip_text = _("Silent");
                notify_active = false;
            }
        }
    }
}
