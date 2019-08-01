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
    public class Utils  : GLib.Object {
        public Utils () {}
        construct { }

        public static string cache_folder () {
            string output = "%s".printf (Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_cache_dir (), Environment.get_application_name()));
            return output;
        }

        public static string audiovideo (string input) {
            string output;
            if ("aac ac3 aiff flac mmf mp3 m4a wma ogg wav".contains (input)) {
                output = "%s".printf ("Audio");
            } else if ("mp4 flv webm avi mpg mpeg mkv".contains (input)) {
                output = "%s".printf ("Video");
            } else {
                output = "%s".printf ("A / V");
                }
            return output;
        }

        public static string limitstring (string input) {
            string output;
	        if (input.char_count ()  > 26) {
                output = "%s".printf (input.substring (0, 25 - 0) + "…");
            } else {
                output = "%s".printf (input);
            }
            return output;
        }
    }
}
