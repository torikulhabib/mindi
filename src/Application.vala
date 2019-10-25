/*
* Copyright (c) {2018} torikulhabib (https://github.com/torikulhabib/com.github.torikulhabib.mindi)
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
* Authored by: torikulhabib <torik.habib@Gmail.com>
*/

namespace Mindi {
    public class MindiApp : Gtk.Application {
        public static GLib.Settings settings;
        private Window window = null;
        public MindiApp () {
            Object(
                application_id: "com.github.torikulhabib.mindi",
                flags: ApplicationFlags.HANDLES_OPEN
            );

            var quit_action = new SimpleAction ("quit", null);
            quit_action.activate.connect (() => {
                if (window != null) {
                    window.signal_close ();
                }
            });
            add_action (quit_action);
            set_accels_for_action ("app.quit", {"<Ctrl>Q", "Escape"});
        }
        private static MindiApp mindiapp = null;
        public static MindiApp get_instance () {
            if (mindiapp == null)
                mindiapp = new MindiApp ();
            return mindiapp;
        }

        construct {
            settings = new Settings ("com.github.torikulhabib.mindi");
        }

        public override void open (File[] files, string hint) {
            var streampc = new StreamPc ();
            streampc = StreamPc.instance;
            if (MindiApp.settings.get_boolean ("stream-mode")) {
                streampc.stream_button_click ();
            }
            activate ();
            if (files [0].query_exists ()) {
                window.selected_video = files [0];
            }
        }

        public override void activate () {
            if (get_windows ().length () > 0) {
                get_windows ().data.present ();
                return;
            }
            window = new Window (this);
            window.set_application(this);
            window.show_all ();
        }
}
        public static void main (string[] args) {
            var app = new MindiApp ();
            app.run (args);
        }

}
