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

    public class ObjectConverter : GLib.Object {

        static ObjectConverter _instance = null;
        public static ObjectConverter instance {
            get {
                if (_instance == null)
                    _instance = new ObjectConverter ();
                return _instance;
            }
        }

        private ObjectConverter () {}

        construct {
            is_running = false;
            begin.connect (() => {
                is_running = true;
            });
            finished.connect (() => {
                is_running = false;
            });
        }

        public bool is_running {get;set;}
        public signal void begin ();
        public signal void finished (bool success);
        Pid child_pid;
        public async void converter_now (File video, Mindi.Formataudios formataudio) {
            begin ();
            string[] spawn_args;
            string filevideo = video.get_path ();
            switch (formataudio) {
                case Mindi.Formataudios.MP3:
                var mp3_path = GLib.Path.build_filename (filevideo +".mp3");
                    spawn_args = {"ffmpeg", "-y", "-i", filevideo, "-acodec", "libmp3lame", "-b:a", "160k", "-ac", "2", "-ar", "44100", mp3_path};
                    break;
                case Mindi.Formataudios.M4A:
                var m4a_path = GLib.Path.build_filename (filevideo + ".m4a");
                    spawn_args = {"ffmpeg", "-y", "-i", filevideo, "-vn", "-acodec", "aac", "-strict", "experimental", "-b:a", "112k", "-ac", "2", "-ar", "48000", m4a_path};
                    break;
                case Mindi.Formataudios.OGG:
                var ogg_path = GLib.Path.build_filename (filevideo + ".ogg");
                    spawn_args = {"ffmpeg", "-y", "-i", filevideo, "-acodec", "libvorbis", "-aq", "3", "-vn", "-ac", "2", ogg_path};
                    break;
                case Mindi.Formataudios.WMA:
                var wma_path = GLib.Path.build_filename (filevideo + ".wma");
                    spawn_args = {"ffmpeg", "-y", "-i", filevideo, "-vn", "-acodec", "wmav2", "-b:a", "160k", "-ac", "2", wma_path};
                    break;
                case Mindi.Formataudios.WAV:
                var wav_path = GLib.Path.build_filename (filevideo + ".wav");
                    spawn_args = {"ffmpeg", "-y", "-i", filevideo, "-vn", "-ar", "44100", wav_path};
                    break;

                default:
                    assert_not_reached ();
            }

            try {
                    Process.spawn_async_with_pipes (
                    "/",
                    spawn_args,
                    null,
                    SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                    null,
                    out child_pid,
                    null);
            } catch (GLib.SpawnError e) {
                stdout.printf ("GLibSpawnError: %s\n", e.message);
            }

            ChildWatch.add (child_pid, (pid, status) => {
                        Process.close_pid (pid);
                        finished (status == 0);
                    });
        }
    }
}
