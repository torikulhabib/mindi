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
    public enum Formataudios {
        MP3,
        M4A,
        OGG,
        WMA,
        WAV;

        public string get_name () {
            switch (this) {
                case MP3:
                    return "MP3";

                case M4A:
                    return "M4A";

                case OGG:
                    return "OGG";

                case WMA:
                    return "WMA";

                case WAV:
                    return "WAV";

                default:
                    assert_not_reached ();
            }
        }

        public static Formataudios [] get_all () {
            return { MP3, M4A, OGG, WMA, WAV };
        }
    }

    public class Formataudio : Gtk.FlowBoxChild  {
        Gtk.Grid content;
        Gtk.Label title;

        public Formataudios formataudio { get; private set; }

        construct {
            content = new Gtk.Grid ();
            content.row_spacing = 12;
            content.valign = Gtk.Align.CENTER;
            this.add (content);
        }

        public Formataudio (Formataudios formataudio) {
            this.formataudio = formataudio;

            title = new Gtk.Label (formataudio.get_name ());
            title.margin_top = 6;
            title.margin_bottom = 6;
            title.margin_start = 12;
            title.margin_end = 12;
            content.attach (title, 0, 0, 1, 1);
        }
    }
}
