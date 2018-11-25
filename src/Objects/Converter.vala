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

using Gtk;

namespace Mindi {
    public class ObjectConverter : Grid {

        static ObjectConverter _instance = null;
        public static ObjectConverter instance {
            get {
                if (_instance == null)
                    _instance = new ObjectConverter ();
                return _instance;
            }
        }

        private Box         container;
        private Box         box_name_progress;
        private ProgressBar progress_bar;
        private Label       status;
        private double progress;

        public bool is_running {get;set;}
        public signal void begin ();
        public signal void finished (bool success);
        private string[] cmd;

        public ObjectConverter () {}

        construct {
            container = new Box (Orientation.HORIZONTAL, 0);
            container.margin = 5;
            box_name_progress = new Box (Orientation.VERTICAL, 0);
            progress_bar = new ProgressBar ();
            progress_bar.set_fraction (progress);
            status = new Label ("Starting");
            status.halign = Align.START;
            box_name_progress.pack_start (progress_bar);
            box_name_progress.pack_start (status);
            container.pack_start (box_name_progress);
            row_spacing = 10;
            width_request = 16;
            column_homogeneous = true;
            add(container);
            show_all ();

            is_running = false;
            begin.connect (() => {
                is_running = true;
            });
            finished.connect (() => {
                is_running = false;
            });
        }

        public async void cancel_now () {
               string[] spawn_args = {"killall","ffmpeg"};
               string[] spawn_env = Environ.get ();
               try {
                        Process.spawn_sync (
                        "/",
                        spawn_args,
                        spawn_env,
                        SpawnFlags.SEARCH_PATH,
                        null,
                        null,
                        null,
                        null);
                } catch (GLib.SpawnError e) {
                    stdout.printf ("GLibSpawnError: %s\n", e.message);
                }
        }

        public async void converter_now (File video, Mindi.Formataudios formataudio) {
            begin ();
            string inputvideo = video.get_path ();
	        string [] input = inputvideo.split (".");
            string outputvideo = input [0];

            switch (formataudio) {
                case Mindi.Formataudios.AC3:
                var ac3_path = GLib.Path.build_filename (outputvideo +".ac3");
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, "-f", "ac3", "-acodec", "ac3", "-b:a", "192k", "-ar", "48000", "-ac", "2", ac3_path};
                    break;
                case Mindi.Formataudios.AIFF:
                var aiff_path = GLib.Path.build_filename (outputvideo +".aif");
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, aiff_path};
                    break;
                case Mindi.Formataudios.FLAC:
                var flac_path = GLib.Path.build_filename (outputvideo +".flac");
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, "-c:a", "flac", flac_path};
                    break;
                case Mindi.Formataudios.MMF:
                var mmf_path = GLib.Path.build_filename (outputvideo +".mmf");
                    cmd = {"ffmpeg", "-y", "-i", inputvideo,  "-strict", "-2", "-ar", "44100", mmf_path};
                    break;
                case Mindi.Formataudios.MP3:
                var mp3_path = GLib.Path.build_filename (outputvideo +".mp3");
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, "-acodec", "libmp3lame", "-b:a", "160k", "-ac", "2", "-ar", "44100", mp3_path};
                    break;
                case Mindi.Formataudios.M4A:
                var m4a_path = GLib.Path.build_filename (outputvideo + ".m4a");
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, "-vn", "-acodec", "aac", "-strict", "experimental", "-b:a", "112k", "-ac", "2", "-ar", "48000", m4a_path};
                    break;
                case Mindi.Formataudios.OGG:
                var ogg_path = GLib.Path.build_filename (outputvideo + ".ogg");
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, "-acodec", "libvorbis", "-aq", "3", "-vn", "-ac", "2", ogg_path};
                    break;
                case Mindi.Formataudios.WMA:
                var wma_path = GLib.Path.build_filename (outputvideo + ".wma");
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, "-vn", "-acodec", "wmav2", "-b:a", "160k", "-ac", "2", wma_path};
                    break;
                case Mindi.Formataudios.WAV:
                var wav_path = GLib.Path.build_filename (outputvideo + ".wav");
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, "-vn", "-ar", "44100", wav_path};
                    break;
                default:
                var aac_path = GLib.Path.build_filename (outputvideo +".aac");
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, "-strict", "experimental", "-c:a", "aac", "-b:a", "128k", aac_path};
                    break;
                 }
            try {
                    SubprocessLauncher launcher = new SubprocessLauncher (SubprocessFlags.STDERR_PIPE);
                    Subprocess subprocess       = launcher.spawnv (cmd);
                    InputStream input_stream    = subprocess.get_stderr_pipe ();
                    int error                   = 0;

                    convert_async.begin (input_stream, error, (obj, async_res) => {
                        try {
                            if (subprocess.wait_check ()) {
                                finished (true);
                            }
                        } catch (Error e) {
                                GLib.warning ("Error: %s\n", e.message);
                                finished (false);
                        }
                    });
                } catch (Error e) {
                        GLib.warning ("Error: %s\n", e.message);
                }
        }

        private async void convert_async (InputStream input_stream, int error) {
            try {
                var charset_converter   = new CharsetConverter ("utf-8", "iso-8859-1");
                var costream            = new ConverterInputStream (input_stream, charset_converter);
                var data_input_stream   = new DataInputStream (costream);
                data_input_stream.set_newline_type (DataStreamNewlineType.ANY);

                int total = 0;

                while (true) {
                    string str_return = yield data_input_stream.read_line_utf8_async ();
                    if (str_return == null) {
                        break; 
                    } else {
                        process_line (str_return, ref total, error);
                    }
                }
            } catch (Error e) {
                GLib.critical ("Error: %s\n", e.message);
            }
        }

        private void process_line (string str_return, ref int total, int error) {
            string time     = StringUtil.EMPTY;
            string size     = StringUtil.EMPTY;
            string bitrate  = StringUtil.EMPTY;

            if (str_return.contains ("Duration:")) {
                int index       = str_return.index_of ("Duration:");
                string duration = str_return.substring (index + 10, 11);

                total = TimeUtil.duration_in_seconds (duration);
            }

            if (str_return.contains ("time=") && str_return.contains ("size=") && str_return.contains ("bitrate=") ) {
                int index_time  = str_return.index_of ("time=");
                time            = str_return.substring ( index_time + 5, 11);
                int loading     = TimeUtil.duration_in_seconds (time);
                double progress = (100 * loading) / total;
                progress_bar.set_fraction (progress / 100);
                int index_size  = str_return.index_of ("size=");
                size            = str_return.substring ( index_size + 5, 11);
                int index_bitrate = str_return.index_of ("bitrate=");
                bitrate           = str_return.substring ( index_bitrate + 8, 11);

                status.label = "Run: " + progress.to_string () + " % " + " Size: " + size.strip () + " Rate: " + bitrate.strip ();
            }
        }

        public async void remove_failed (File video, Mindi.Formataudios formataudio) {
            string[] spawn_args;
		    string[] spawn_env = Environ.get ();
            string inputvideo = video.get_path ();
	        string [] input = inputvideo.split (".");
            string outputvideo = input [0];

            switch (formataudio) {
                case Mindi.Formataudios.AC3:
                var ac3_path = GLib.Path.build_filename (outputvideo +".ac3");
                    spawn_args = {"rm", "-rf", ac3_path};
                    break;
                case Mindi.Formataudios.AIFF:
                var aiff_path = GLib.Path.build_filename (outputvideo +".aif");
                    spawn_args = {"rm", "-rf", aiff_path};
                    break;
                case Mindi.Formataudios.FLAC:
                var flac_path = GLib.Path.build_filename (outputvideo +".flac");
                    spawn_args = {"rm", "-rf", flac_path};
                    break;
                case Mindi.Formataudios.MMF:
                var mmf_path = GLib.Path.build_filename (outputvideo +".mmf");
                    spawn_args = {"rm", "-rf", mmf_path};
                    break;
                case Mindi.Formataudios.MP3:
                var mp3_path = GLib.Path.build_filename (outputvideo +".mp3");
                    spawn_args = {"rm", "-rf", mp3_path};
                    break;
                case Mindi.Formataudios.M4A:
                var m4a_path = GLib.Path.build_filename (outputvideo + ".m4a");
                    spawn_args = {"rm", "-rf", m4a_path};
                    break;
                case Mindi.Formataudios.OGG:
                var ogg_path = GLib.Path.build_filename (outputvideo + ".ogg");
                    spawn_args = {"rm", "-rf", ogg_path};
                    break;
                case Mindi.Formataudios.WMA:
                var wma_path = GLib.Path.build_filename (outputvideo + ".wma");
                    spawn_args = {"rm", "-rf", wma_path};
                    break;
                case Mindi.Formataudios.WAV:
                var wav_path = GLib.Path.build_filename (outputvideo + ".wav");
                    spawn_args = {"rm", "-rf", wav_path};
                    break;
                default:
                var aac_path = GLib.Path.build_filename (outputvideo +".aac");
                    spawn_args = {"rm", "-rf", aac_path};
                    break;
            }

                try {
                        Process.spawn_sync (
                        "/",
                        spawn_args,
                        spawn_env,
                        SpawnFlags.SEARCH_PATH,
                        null,
                        null,
                        null,
                        null);
                } catch (GLib.SpawnError e) {
                    stdout.printf ("GLibSpawnError: %s\n", e.message);
                }
        }
    }
}
