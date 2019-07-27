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
        private ProgressBar progress_bar;
        private Label status;
        private uint timer;
        public string notify_string;
        private bool is_active {get;set;}
        public bool is_running {get;set;default = false;}
        public bool is_downloading {get;set;default = false;}
        public bool is_converting {get;set;default = false;}
        public signal void downloading ();
        public signal void converting ();
        public signal void begin (bool now_converting);
        public signal void finished (bool success);
        public signal void warning_notif (bool notify);
        public string ac3_path;
        public string aiff_path;
        public string flac_path;
        public string mmf_path;
        public string mp3_path;
        public string m4a_path;
        public string ogg_path;
        public string wma_path;
        public string wav_path;
        public string aac_path;
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
            var container = new Box (Orientation.HORIZONTAL, 0);
            container.margin = 5;
            var box_name_progress = new Box (Orientation.VERTICAL, 0);
            progress_bar = new ProgressBar ();
            status = new Label (_("Starting"));
            status.ellipsize = Pango.EllipsizeMode.END;
            status.max_width_chars = 36;
            status.halign = Align.START;
            box_name_progress.pack_start (progress_bar);
            box_name_progress.pack_start (status);
            container.pack_start (box_name_progress);
            row_spacing = 10;
            width_request = 16;
            column_homogeneous = true;
            add(container);
            show_all ();

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
            get_folder_data (cache_dir_path, File.new_for_path (cache_dir_path), " ");
        }

        public async void get_video (string uri, bool stream, bool finish) {
            downloading ();
            mindi_desktop_visible ();
            cache_dir_path = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_cache_dir (), Environment.get_application_name());
            string ignore_name = "" + name_file_stream;
            string up = ignore_name.up ();
            if (up.contains ("")) {
               if (up.has_suffix (".PART") == true) {
                get_video_stream (uri, stream, finish);
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
	                get_video_stream (uri, stream, finish);
                } else {
	                get_video_stream (uri, stream, finish);
	            }
            }
        }

	    private void get_video_stream (string uri, bool stream, bool finish) {
	    	string [] spawn_args;
            string [] spawn_env = Environ.get ();

            cache_dir_path = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_cache_dir (), Environment.get_application_name());
            var cache_dir = File.new_for_path (cache_dir_path);
            if (!cache_dir.query_exists ()) {
                try {
                    cache_dir.make_directory_with_parents ();
                } catch (Error e) {
                    warning (e.message);
                }
            }

            if (stream && finish) {
		        spawn_args = {"youtube-dl", "-f", "251", "-o", "%(title)s.%(ext)s" , uri};
		    } else if (stream && !finish) {
		        spawn_args = {"youtube-dl", "-f", "140", "-o", "%(title)s.%(ext)s" , uri};
		    } else {
		        spawn_args = {"youtube-dl", "-o", "%(title)s.%(ext)s" , uri};
		    }
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
                                mindi_desktop (0, 0);
                                Timeout.add_seconds (1,() => {
                                    Source.remove (timer);
                                    return false;
                                });
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
                   if (up.has_suffix (".PART") == true) {
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
                        mindi_desktop (0, 0);
	                    finished (true);
                        Timeout.add_seconds (1,() => {
                            Source.remove (timer);
                            return false;
                        });
	                    break;
	                }
                }
            }
	    }

        public async void cancel_now () {
            subprocess.force_exit ();
        }

        public async void set_folder (File video, bool stream_active) {
            cache_dir_path = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_cache_dir (), Environment.get_application_name());
                if (stream_active) {
                    inputvideo = cache_dir_path + "/" + name_file_stream;
	                int i = name_file_stream.last_index_of (".");
	                string [] inputbase = name_file_stream.split ("." + name_file_stream.substring (i + 1));
                    outputname = inputbase [0];
                    outputvideo = MindiApp.settings.get_string ("folder-link") + inputbase [0];
                } else {
                    inputvideo = video.get_path ();
	                int i = video.get_basename ().last_index_of (".");
	                string [] inputbase = video.get_basename ().split ("." + video.get_basename ().substring (i + 1));
                    outputname = inputbase [0];
	                string [] input = inputvideo.split ("." + video.get_basename ().substring (i + 1));
                    outputvideo = input [0];
                }

                foldersave = MindiApp.settings.get_string ("output-folder");
                ask_location = MindiApp.settings.get_string ("ask-location");
                switch (Mindi.Configs.Settings.get_settings ().folder_mode) {
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
            mindi_desktop_visible ();
            string [] spawn_args;
		    string [] spawn_env = Environ.get ();

            switch (formataudio) {
                case Mindi.Formataudios.AC3:
                    spawn_args = {"ffmpeg", "-i", inputvideo, "-f", "ac3", "-acodec", "ac3", "-b:a", "192k", "-ar", "48000", "-ac", "2", ac3_path};
                    break;
                case Mindi.Formataudios.AIFF:
                    spawn_args = {"ffmpeg", "-i", inputvideo, aiff_path};
                    break;
                case Mindi.Formataudios.FLAC:
                    spawn_args = {"ffmpeg", "-i", inputvideo, "-c:a", "flac", flac_path};
                    break;
                case Mindi.Formataudios.MMF:
                    spawn_args = {"ffmpeg", "-i", inputvideo,  "-strict", "-2", "-ar", "44100", mmf_path};
                    break;
                case Mindi.Formataudios.MP3:
                    spawn_args = {"ffmpeg", "-i", inputvideo, "-acodec", "libmp3lame", "-b:a", "160k", "-ac", "2", "-ar", "44100", mp3_path};
                    break;
                case Mindi.Formataudios.M4A:
                    spawn_args = {"ffmpeg", "-i", inputvideo, "-vn", "-acodec", "aac", "-strict", "experimental", "-b:a", "112k", "-ac", "2", "-ar", "48000", m4a_path};
                    break;
                case Mindi.Formataudios.OGG:
                    spawn_args = {"ffmpeg", "-i", inputvideo, "-acodec", "libvorbis", "-aq", "3", "-vn", "-ac", "2", ogg_path};
                    break;
                case Mindi.Formataudios.WMA:
                    spawn_args = {"ffmpeg", "-i", inputvideo, "-vn", "-acodec", "wmav2", "-b:a", "160k", "-ac", "2", wma_path};
                    break;
                case Mindi.Formataudios.WAV:
                    spawn_args = {"ffmpeg", "-i", inputvideo, "-vn", "-ar", "44100", wav_path};
                    break;
                default:
                    spawn_args = {"ffmpeg", "-i", inputvideo, "-strict", "experimental", "-c:a", "aac", "-b:a", "128k", aac_path};
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
                                    Source.remove (timer);
                                    mindi_desktop (0, 0);
                                    return false;
                                });
                            }
                        } catch (Error e) {
                            GLib.warning (e.message);
                            progress_bar.set_fraction (0);
                            mindi_desktop (0, 0);
                                Timeout.add (500,() => {
                                    finished (false);
                                    return false;
                                });
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
            if (str_return.contains ("already exists. Overwrite ? [y/N]")) {
                int index_first_name        = str_return.index_of ("File '");
                int index_end_name          = str_return.index_of ("' already exists. Overwrite ? [y/N]");
                notify_string               = str_return.substring ( index_first_name + 6, index_end_name - 6);
                warning_notif (true);
                Source.remove (timer);
            } else {
                warning_notif (false);
            }
            if (str_return.contains ("[download]") && str_return.contains ("of ") && str_return.contains ("at") ) {
                double progress_value       = double.parse(str_return.slice(str_return.index_of(" "), str_return.index_of("%")).strip());
                int64 progress_badge        = int64.parse(str_return.slice(str_return.index_of(" "), str_return.index_of("%")).strip());
                int index_size              = str_return.index_of ("of");
                int index_speed             = str_return.index_of ("at");
                string size                 = str_return.substring ( index_size + 3, index_speed - (index_size + 3));
                int index_end               = str_return.index_of ("ETA");
                string eta                  = str_return.substring ( index_end + 4, 5);
                string speed                = str_return.substring ( index_speed + 2, index_end - (index_speed + 2));
                status.label                = _("Run: ") + progress_badge.to_string () + " % " + _("Size: ") + size.strip () + " " + _("Rate: ") + speed.strip ();
                progress_bar.tooltip_text   = (_("Run: ") + progress_badge.to_string () + " % " + _("Size: ") + size.strip () + " " + _("Transfer Rate: ") + speed.strip () + " " + _("ETA: ") + eta.strip ());
                progress_bar.set_fraction (progress_value / 100);
                mindi_desktop (progress_badge, progress_value / 100);
            }

            if (str_return.contains ("Duration:")) {
                int index                   = str_return.index_of ("Duration:");
                string duration             = str_return.substring (index + 10, 11);
                total = TimeUtil.duration_in_seconds (duration);
            }

            if (str_return.contains ("time=") && str_return.contains ("size=") && str_return.contains ("bitrate=") ) {
                int index_time              = str_return.index_of ("time=");
                string time                 = str_return.substring ( index_time + 5, 11);
                int loading                 = TimeUtil.duration_in_seconds (time);
                double progress             = (100 * loading) / total;
                int64 progress_badge        = (100 * loading) / total;
                double progress_value       = progress / 100;
                int index_size              = str_return.index_of ("size=");
                string size                 = str_return.substring ( index_size + 5, 11);
                int index_bitrate           = str_return.index_of ("bitrate=");
                string bitrate              = str_return.substring ( index_bitrate + 8, 11);
                int index_speed           = str_return.index_of ("speed=");
                string speed              = str_return.substring ( index_speed + 6, 9);
                status.label                = _("Run: ") + progress.to_string () + " % " + _("Size: ") + size.strip () + " " + _("Bitrate: ") + bitrate.strip ();
                progress_bar.tooltip_text   = (_("Run: ") + progress.to_string () + " % " + _("Size: ") + size.strip () + " " + _("Time: ") + time.strip () + " " + _("Bitrate: ") + bitrate.strip () + " " + _("Speed: ") + speed.strip ());
                progress_bar.set_fraction (progress_value);
                mindi_desktop (progress_badge, progress_value);
            }
        }

        private void mindi_desktop (int64 badge, double progress) {
            Mindi.Services.Application.set_progress.begin (progress, (obj, res) => {
                try {
                    Mindi.Services.Application.set_progress.end (res);
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
            Mindi.Services.Application.set_badge.begin (badge, (obj, res) => {
                try {
                    Mindi.Services.Application.set_badge.end (res);
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
        }

        public void is_active_signal (bool is_actived) {
            is_active = is_running == true ?  is_actived : true;
        }

        public void mindi_desktop_visible () {
            timer = Timeout.add (100, () => {
                Mindi.Services.Application.set_progress_visible.begin (!is_active, (obj, res) => {
                    try {
                        Mindi.Services.Application.set_progress_visible.end (res);
                    } catch (GLib.Error e) {
                        critical (e.message);
                    }
                });
                Mindi.Services.Application.set_badge_visible.begin (!is_active, (obj, res) => {
                    try {
                        Mindi.Services.Application.set_badge_visible.end (res);
                    } catch (GLib.Error e) {
                        critical (e.message);
                    }
               });
                return true;
            });
        }
    }
}
