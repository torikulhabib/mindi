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
using Mindi.Configs;

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
        private string [] cmd;
        private string ac3_path;
        private string aiff_path;
        private string flac_path;
        private string mmf_path;
        private string mp3_path;
        private string m4a_path;
        private string ogg_path;
        private string wma_path;
        private string wav_path;
        private string aac_path;
        private string inputvideo;
        private string foldersave;
        private string asksave;

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

        public async void set_folder (File video) {
                var settings = Mindi.Configs.Settings.get_settings ();
                inputvideo = video.get_path ();
                string inputname = video.get_basename ();
	            string [] input = inputvideo.split (".");
	            string [] inputbase = inputname.split (".");
                string outputvideo = input [0];
                string outputname = inputbase [0];
                foldersave = MindiApp.settings.get_string ("output-folder");
                asksave = MindiApp.settings.get_string ("ask-folder");
                switch (settings.folder_mode) {
                case FolderMode.PLACE :
                    ac3_path = GLib.Path.build_filename (outputvideo +".ac3");
                    aiff_path = GLib.Path.build_filename (outputvideo +".aif");
                    flac_path = GLib.Path.build_filename (outputvideo +".flac");
                    mmf_path = GLib.Path.build_filename (outputvideo +".mmf");
                    mp3_path = GLib.Path.build_filename (outputvideo +".mp3");
                    m4a_path = GLib.Path.build_filename (outputvideo + ".m4a");
                    ogg_path = GLib.Path.build_filename (outputvideo + ".ogg");
                    wma_path = GLib.Path.build_filename (outputvideo + ".wma");
                    wav_path = GLib.Path.build_filename (outputvideo + ".wav");
                    aac_path = GLib.Path.build_filename (outputvideo +".aac");
                    break;
                case FolderMode.CUSTOM :
                    ac3_path = GLib.Path.build_filename (foldersave+"/"+outputname +".ac3");
                    aiff_path = GLib.Path.build_filename (foldersave+"/"+outputname +".aif");
                    flac_path = GLib.Path.build_filename (foldersave+"/"+outputname +".flac");
                    mmf_path = GLib.Path.build_filename (foldersave+"/"+outputname +".mmf");
                    mp3_path = GLib.Path.build_filename (foldersave+"/"+outputname +".mp3");
                    m4a_path = GLib.Path.build_filename (foldersave+"/"+outputname +".m4a");
                    ogg_path = GLib.Path.build_filename (foldersave+"/"+outputname +".ogg");
                    wma_path = GLib.Path.build_filename (foldersave+"/"+outputname +".wma");
                    wav_path = GLib.Path.build_filename (foldersave+"/"+outputname +".wav");
                    aac_path = GLib.Path.build_filename (foldersave+"/"+outputname +".aac");
                    break;
                case FolderMode.ASK :
                    ac3_path = GLib.Path.build_filename (asksave+"/"+outputname +".ac3");
                    aiff_path = GLib.Path.build_filename (asksave+"/"+outputname +".aif");
                    flac_path = GLib.Path.build_filename (asksave+"/"+outputname +".flac");
                    mmf_path = GLib.Path.build_filename (asksave+"/"+outputname +".mmf");
                    mp3_path = GLib.Path.build_filename (asksave+"/"+outputname +".mp3");
                    m4a_path = GLib.Path.build_filename (asksave+"/"+outputname +".m4a");
                    ogg_path = GLib.Path.build_filename (asksave+"/"+outputname +".ogg");
                    wma_path = GLib.Path.build_filename (asksave+"/"+outputname +".wma");
                    wav_path = GLib.Path.build_filename (asksave+"/"+outputname +".wav");
                    aac_path = GLib.Path.build_filename (asksave+"/"+outputname +".aac");
                    break;
                }
            }

        public async void converter_now (Mindi.Formataudios formataudio) {
            begin ();
            switch (formataudio) {
                case Mindi.Formataudios.AC3:
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, "-f", "ac3", "-acodec", "ac3", "-b:a", "192k", "-ar", "48000", "-ac", "2", ac3_path};
                    break;
                case Mindi.Formataudios.AIFF:
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, aiff_path};
                    break;
                case Mindi.Formataudios.FLAC:
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, "-c:a", "flac", flac_path};
                    break;
                case Mindi.Formataudios.MMF:
                    cmd = {"ffmpeg", "-y", "-i", inputvideo,  "-strict", "-2", "-ar", "44100", mmf_path};
                    break;
                case Mindi.Formataudios.MP3:
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, "-acodec", "libmp3lame", "-b:a", "160k", "-ac", "2", "-ar", "44100", mp3_path};
                    break;
                case Mindi.Formataudios.M4A:
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, "-vn", "-acodec", "aac", "-strict", "experimental", "-b:a", "112k", "-ac", "2", "-ar", "48000", m4a_path};
                    break;
                case Mindi.Formataudios.OGG:
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, "-acodec", "libvorbis", "-aq", "3", "-vn", "-ac", "2", ogg_path};
                    break;
                case Mindi.Formataudios.WMA:
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, "-vn", "-acodec", "wmav2", "-b:a", "160k", "-ac", "2", wma_path};
                    break;
                case Mindi.Formataudios.WAV:
                    cmd = {"ffmpeg", "-y", "-i", inputvideo, "-vn", "-ar", "44100", wav_path};
                    break;
                default:
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
                                progress_bar.set_fraction (0);
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

        public async void remove_failed (Mindi.Formataudios formataudio) {
            string[] spawn_args;
		    string[] spawn_env = Environ.get ();

            switch (formataudio) {
                case Mindi.Formataudios.AC3:
                    spawn_args = {"rm", "-rf", ac3_path};
                    break;
                case Mindi.Formataudios.AIFF:
                    spawn_args = {"rm", "-rf", aiff_path};
                    break;
                case Mindi.Formataudios.FLAC:
                    spawn_args = {"rm", "-rf", flac_path};
                    break;
                case Mindi.Formataudios.MMF:
                    spawn_args = {"rm", "-rf", mmf_path};
                    break;
                case Mindi.Formataudios.MP3:
                    spawn_args = {"rm", "-rf", mp3_path};
                    break;
                case Mindi.Formataudios.M4A:
                    spawn_args = {"rm", "-rf", m4a_path};
                    break;
                case Mindi.Formataudios.OGG:
                    spawn_args = {"rm", "-rf", ogg_path};
                    break;
                case Mindi.Formataudios.WMA:
                    spawn_args = {"rm", "-rf", wma_path};
                    break;
                case Mindi.Formataudios.WAV:
                    spawn_args = {"rm", "-rf", wav_path};
                    break;
                default:
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
