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
        AAC = 0,
        AC3 = 1,
        AIFF = 2,
        FLAC = 3,
        MMF = 4,
        MP3 = 5,
        M4A = 6,
        OGG = 7,
        WMA = 8,
        WAV = 9;

        public string get_name () {
            switch (this) {
                case AC3:
                    return "AC3";

                case AIFF:
                    return "AIFF";

                case FLAC:
                    return "FLAC";

                case MMF:
                    return "MMF";

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
                    return "AAC";
            }
        }

        public static Formataudios [] get_all () {
            return { AAC, AC3, AIFF, FLAC, MMF, MP3, M4A, OGG, WMA, WAV };
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
