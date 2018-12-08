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
using GLib;

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

        private Box container;
        private Box box_name_progress;
        private ProgressBar progress_bar;
        private Label status;
        private double progress;

        public bool is_running {get;set;}
        public bool is_downloading {get;set;}
        public bool is_converting {get;set;}
        public signal void downloading ();
        public signal void converting ();
        public signal void begin (bool now_converting);
        public signal void finished (bool success);
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
        private string outputvideo;
        private string outputname;
        private string foldersave;
        private string ask_location;
        public string name_file_stream;
        private string cache_dir_path;
        private Subprocess? subprocess;
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
            is_converting = false;
            is_downloading = false;
            converting.connect (() => {
                is_converting = true;
                begin (true);
            });
            downloading.connect (() => {
                is_downloading = true;
                begin (false);
            });
            begin.connect (() => {
                is_running = true;
            });
            finished.connect (() => {
                is_running = false;
                Timeout.add_seconds (1,() => {
                    is_converting = false;
                    is_downloading = false;
                    return false;
	            });
            });
        }

        private void get_folder_data (string cache, File file, string name = "") {
            var cache_dir = File.new_for_path (cache);
            if (cache_dir.query_exists ()) {
            try {
                var enumerator = file.enumerate_children ("", FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
                FileInfo info = null;
                while ((info = enumerator.next_file ()) != null) {
                    if (info.get_file_type () == FileType.DIRECTORY) {
                       File subdir = file.resolve_relative_path (info.get_name ());
                        get_folder_data (cache, subdir, name = "");
                    } else {
                        name_file_stream = info.get_name ();
                    }
                }
            } catch (Error e) {
                GLib.warning (e.message);
            }
            }
        }

        public async void read_name () {
            cache_dir_path = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_cache_dir (), Environment.get_application_name());
            File cache_dir_source = File.new_for_path (cache_dir_path);
            get_folder_data (cache_dir_path, cache_dir_source, "");
        }

        public async void get_video (string uri) {
            downloading ();
            cache_dir_path = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_cache_dir (), Environment.get_application_name());
            string ignore_name = "" + name_file_stream;
            string up = ignore_name.up ();
            if (up.contains ("")) {
               if (up.contains ("PART")) {
                get_video_youtube (uri);
                } else if (up.contains (".")) {
                    string check_file = Path.build_path (Path.DIR_SEPARATOR_S, cache_dir_path, ignore_name);
                    if (File.new_for_path (check_file).query_exists ()) {
                        File file = File.new_for_path (check_file);
	                    try {
		                    file.delete ();
	                    } catch (Error e) {
                            GLib.warning (e.message);
	                    }
	                    }
	                get_video_youtube (uri);
                } else {
	                get_video_youtube (uri);
	            }
            }
        }

	    private void get_video_youtube (string uri) {
            cache_dir_path = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_cache_dir (), Environment.get_application_name());
            var cache_dir = File.new_for_path (cache_dir_path);
            if (!cache_dir.query_exists ()) {
                try {
                    cache_dir.make_directory_with_parents ();
                } catch (Error e) {
                    warning (e.message);
                }
            }

		    string [] spawn_args = {"youtube-dl", "-f", "251", "-o", "%(title)s.%(ext)s" , uri};
            string [] spawn_env = Environ.get ();
            try {
                    SubprocessLauncher launcher = new SubprocessLauncher (SubprocessFlags.STDOUT_PIPE);
                    launcher.set_cwd (cache_dir_path);
                    launcher.set_environ (spawn_env);
                    subprocess = launcher.spawnv (spawn_args);
                    InputStream input_stream    = subprocess.get_stdout_pipe ();

                    convert_async.begin (input_stream, (obj, async_res) => {
                        try {
                            if (subprocess.wait_check ()) {

                                subprocess.get_successful ();
                                Timeout.add_seconds (1,() => {
                                    remove_part.begin ();
                                    return false;
                                });
                            }
                        } catch (Error e) {
                                GLib.warning (e.message);
                                finished (false);
                                progress_bar.set_fraction (0);
                        }
                    });
            } catch (Error e) {
                    GLib.warning (e.message);
            }
        }

        private async void remove_part () {
            while (true) {
                read_name.begin ();
                cache_dir_path = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_cache_dir (), Environment.get_application_name());
                string ignore_name = "" + name_file_stream;
                string up = ignore_name.up ();
                if (up.contains ("")) {
                   if (up.contains ("PART")) {
                        string check_file = Path.build_path (Path.DIR_SEPARATOR_S, cache_dir_path, ignore_name);
                        if (File.new_for_path (check_file).query_exists ()) {
                            File file = File.new_for_path (check_file);
	                        try {
		                        file.delete ();
	                        } catch (Error e) {
                                GLib.warning (e.message);
	                        }
	                    }
	                }  else {
                        progress_bar.set_fraction (0);
	                    finished (true);
	                    break;
	                }
                }
            }
	    }

        public async void cancel_now () {
            subprocess.force_exit ();
        }

        public async void set_folder (File video, bool youtube_active) {
            var settings = Mindi.Configs.Settings.get_settings ();
            cache_dir_path = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_cache_dir (), Environment.get_application_name());
                if (youtube_active) {
                    inputvideo = cache_dir_path + "/" + name_file_stream;
	                int i = name_file_stream.last_index_of (".");
                    string out_last = name_file_stream.substring (i + 1);
	                string [] inputbase = name_file_stream.split ("." + out_last);
                    outputname = inputbase [0];
                    string set_link =  MindiApp.settings.get_string ("folder-link");
                    outputvideo = set_link + outputname;
                } else {
                    inputvideo = video.get_path ();
                    string inputname = video.get_basename ();
	                int i = inputname.last_index_of (".");
                    string out_last = inputname.substring (i + 1);
	                string [] inputbase = inputname.split ("." + out_last);
                    outputname = inputbase [0];
	                string [] input = inputvideo.split ("." + out_last);
                    outputvideo = input [0];
                }

                foldersave = MindiApp.settings.get_string ("output-folder");
                ask_location = MindiApp.settings.get_string ("ask-location");
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
                    ac3_path = GLib.Path.build_filename (ask_location+"/"+outputname +".ac3");
                    aiff_path = GLib.Path.build_filename (ask_location+"/"+outputname +".aif");
                    flac_path = GLib.Path.build_filename (ask_location+"/"+outputname +".flac");
                    mmf_path = GLib.Path.build_filename (ask_location+"/"+outputname +".mmf");
                    mp3_path = GLib.Path.build_filename (ask_location+"/"+outputname +".mp3");
                    m4a_path = GLib.Path.build_filename (ask_location+"/"+outputname +".m4a");
                    ogg_path = GLib.Path.build_filename (ask_location+"/"+outputname +".ogg");
                    wma_path = GLib.Path.build_filename (ask_location+"/"+outputname +".wma");
                    wav_path = GLib.Path.build_filename (ask_location+"/"+outputname +".wav");
                    aac_path = GLib.Path.build_filename (ask_location+"/"+outputname +".aac");
                    break;
                }
            }

        public async void converter_now (Mindi.Formataudios formataudio) {
            converting ();
            string [] spawn_args;
		    string [] spawn_env = Environ.get ();

            switch (formataudio) {
                case Mindi.Formataudios.AC3:
                    spawn_args = {"ffmpeg", "-y", "-i", inputvideo, "-f", "ac3", "-acodec", "ac3", "-b:a", "192k", "-ar", "48000", "-ac", "2", ac3_path};
                    break;
                case Mindi.Formataudios.AIFF:
                    spawn_args = {"ffmpeg", "-y", "-i", inputvideo, aiff_path};
                    break;
                case Mindi.Formataudios.FLAC:
                    spawn_args = {"ffmpeg", "-y", "-i", inputvideo, "-c:a", "flac", flac_path};
                    break;
                case Mindi.Formataudios.MMF:
                    spawn_args = {"ffmpeg", "-y", "-i", inputvideo,  "-strict", "-2", "-ar", "44100", mmf_path};
                    break;
                case Mindi.Formataudios.MP3:
                    spawn_args = {"ffmpeg", "-y", "-i", inputvideo, "-acodec", "libmp3lame", "-b:a", "160k", "-ac", "2", "-ar", "44100", mp3_path};
                    break;
                case Mindi.Formataudios.M4A:
                    spawn_args = {"ffmpeg", "-y", "-i", inputvideo, "-vn", "-acodec", "aac", "-strict", "experimental", "-b:a", "112k", "-ac", "2", "-ar", "48000", m4a_path};
                    break;
                case Mindi.Formataudios.OGG:
                    spawn_args = {"ffmpeg", "-y", "-i", inputvideo, "-acodec", "libvorbis", "-aq", "3", "-vn", "-ac", "2", ogg_path};
                    break;
                case Mindi.Formataudios.WMA:
                    spawn_args = {"ffmpeg", "-y", "-i", inputvideo, "-vn", "-acodec", "wmav2", "-b:a", "160k", "-ac", "2", wma_path};
                    break;
                case Mindi.Formataudios.WAV:
                    spawn_args = {"ffmpeg", "-y", "-i", inputvideo, "-vn", "-ar", "44100", wav_path};
                    break;
                default:
                    spawn_args = {"ffmpeg", "-y", "-i", inputvideo, "-strict", "experimental", "-c:a", "aac", "-b:a", "128k", aac_path};
                    break;
                 }
            try {
                    SubprocessLauncher launcher = new SubprocessLauncher (SubprocessFlags.STDERR_PIPE);
                    subprocess = launcher.spawnv (spawn_args);
                    launcher.set_environ (spawn_env);
                    InputStream input_stream    = subprocess.get_stderr_pipe ();

                    convert_async.begin (input_stream, (obj, async_res) => {
                        try {
                            if (subprocess.wait_check ()) {
                                finished (true);
                                subprocess.get_successful ();
                                Timeout.add_seconds (1,() => {
                                    progress_bar.set_fraction (0);
                                    return false;
                                });
                            }
                        } catch (Error e) {
                            GLib.warning (e.message);
                            finished (false);
                            progress_bar.set_fraction (0);
                        }
                    });
                } catch (Error e) {
                        GLib.warning (e.message);
                }
        }

        private async void convert_async (InputStream input_stream) {
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
                        process_line (str_return, ref total);
                    }
                }
            } catch (Error e) {
                GLib.critical (e.message);
            }
        }

        private void process_line (string str_return, ref int total) {
            string time = "";
            string size = "";
            string bitrate = "";

            if (str_return.contains ("[download]")) {
                double progress_value = double.parse(str_return.slice(str_return.index_of(" "), str_return.index_of("%")).strip());
                progress_bar.set_fraction (progress_value / 100);
                string progress_msg = str_return.substring (str_return.index_of (" "));
	            int link_longchar = progress_msg.char_count ();
	            if (link_longchar > 39) {
	                string string_limit = progress_msg.substring (0, 38 - 0);
                    status.label = ("Run:" + string_limit);
                } else {
                    status.label = ("Run:" + progress_msg);
                }
            }

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
                string converting = "Run: " + progress.to_string () + " % " + " Size: " + size.strip () + " Bitrate: " + bitrate.strip ();
                int link_longchar = converting.char_count ();
	            if (link_longchar > 43) {
	                string string_limit = converting.substring (0, 42 - 0);
                    status.label = (string_limit);
                } else {
                    status.label = (converting);
                }
            }
        }

        public async void remove_failed (Mindi.Formataudios formataudio) {
            string failed_removed;
            switch (formataudio) {
                case Mindi.Formataudios.AC3:
                    failed_removed = ac3_path;
                    break;
                case Mindi.Formataudios.AIFF:
                    failed_removed = aiff_path;
                    break;
                case Mindi.Formataudios.FLAC:
                    failed_removed = flac_path;
                    break;
                case Mindi.Formataudios.MMF:
                    failed_removed = mmf_path;
                    break;
                case Mindi.Formataudios.MP3:
                    failed_removed = mp3_path;
                    break;
                case Mindi.Formataudios.M4A:
                    failed_removed = m4a_path;
                    break;
                case Mindi.Formataudios.OGG:
                    failed_removed = ogg_path;
                    break;
                case Mindi.Formataudios.WMA:
                    failed_removed = wma_path;
                    break;
                case Mindi.Formataudios.WAV:
                    failed_removed = wav_path;
                    break;
                default:
                    failed_removed = aac_path;
                    break;
            }
            File file = File.new_for_path (failed_removed);
	            try {
		            file.delete ();
	            } catch (Error e) {
                    GLib.warning ( e.message);
	            }
        }
    }
}
