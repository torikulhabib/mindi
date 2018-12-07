using Gtk;
using Mindi.Configs;

namespace Mindi {
    public class Window : Gtk.ApplicationWindow {
        private Dialog dialog = null;
        private ObjectConverter? converter;

        private Grid content;
        private Button open_video;
        private Image video_logo;
        private Label video_name;
        private Label title_video;
        private Grid video_container;

        private Button select_format;
        private Popover format_popover;
        private Image format_logo;
        private FlowBox format_list;
        private Label format_name;
        private Grid format_container;

        private Grid convert_container;
        private Label convert_label;
        private Button convert_start;
        private Button convert_cancel;

        private Button close_button;
        private LinkButton output_name;
        private LinkButton output_name_location;
        private Label ask_location;

        private Revealer choose_revealer;
        private Revealer convert_revealer;
        private Revealer cancel_revealer;
        private Revealer progressbar_revealer;


        private Image icon_light;
        private Image icon_dark;
        private Image icon_pc;
        private Image ask_icon_folder;
        private Image icon_folder_open;
        private Image icon_folder;
        private Image icon_notify;
        private Image icon_silent;
        private Button notify_button;
        private Button open_button;
        private Button location_button;
        private Button light_dark_button;

        private Stack stack;
        private Image youtube_logo;
        private Stack youtube_stack;
        private Label youtube_name;
        private Button youtube_button;
        private Grid youtube_container;
        private Button open_youtube;
        private Image icon_youtube;
        private Popover add_url_popover;
        private Entry entry;

        private string message;
        private string selected_location;
        private string ask_location_folder;
        private string set_link;
        private bool notify_active {get;set;}
        private bool ask_active {get;set;}
        private bool youtube_active {get;set;}

        Notification desktop_notification;
        Mindi.Widgets.Toast app_notification;

        private GLib.Icon format_icon { 
            owned get {
                return format_logo.gicon;
            }
            set {
                format_logo.set_from_gicon (value, Gtk.IconSize.DIALOG);
            }
        }

        private GLib.Icon video_icon { 
            owned get {
                return video_logo.gicon;
            }
            set {
                video_logo.set_from_gicon (value, Gtk.IconSize.DIALOG);
            }
        }

        File _selected_video = null;
        public File selected_video {
            get { return _selected_video; }
            set {
                _selected_video = value;
                format_container.sensitive = selected_video != null;
                convert_container.sensitive = selected_video != null;

                if (selected_video != null) {
                    open_video.label = _ ("Change");
                    video_name.label = (selected_video.get_basename ());
                    status_location ();
                    input_find_location ();
                    convert_label.label = ("Ready!");
                } else {
                    open_video.label = _ ("Open");
                }
            }
        }

        Mindi.Formataudio _selected_formataudio = null;
        Mindi.Formataudio selected_formataudio {
            get { return _selected_formataudio; }
            set {
                if (selected_formataudio == value) {
                    return;
                }
                _selected_formataudio = value;
                format_name.label = selected_formataudio.formataudio.get_name ();
                update_formataudio_label ();
            }
        }

        public  Window (Gtk.Application application) {
                Object (application: application,
                        icon_name: "com.github.torikulhabib.mindi",
                        resizable: false,
                        hexpand: true
                );
        }

        construct {
            var settings = Mindi.Configs.Settings.get_settings ();
		    settings.notify["light-mode"].connect (() => {
            light_dark_symbol ();
		    });

            icon_light = new Gtk.Image.from_icon_name ("display-brightness-symbolic", Gtk.IconSize.BUTTON);
            icon_dark = new Gtk.Image.from_icon_name ("weather-clear-night-symbolic", Gtk.IconSize.BUTTON);

            light_dark_button = new Button ();
            light_dark_symbol ();
            light_dark_button.tooltip_text = _("Backgrond");
            light_dark_button.clicked.connect (() => {
                settings.light_switch ();
            });

		    settings.notify["folder-mode"].connect (() => {
            folder_symbol ();
		    });

            icon_folder_open = new Gtk.Image.from_icon_name ("document-save-symbolic", Gtk.IconSize.BUTTON);
            icon_folder = new Gtk.Image.from_icon_name ("document-save-as-symbolic", Gtk.IconSize.BUTTON);
            ask_icon_folder = new Gtk.Image.from_icon_name ("system-help-symbolic", Gtk.IconSize.BUTTON);

            location_button = new Gtk.Button ();
            folder_symbol ();
            location_button.tooltip_text = _ ("Output location");
            location_button.clicked.connect (() => {
                if (!converter.is_running) {
                    settings.folder_switch ();
                }
            });

		    settings.notify["notify-mode"].connect (() => {
            notify_symbol ();
		    });

            icon_notify = new Gtk.Image.from_icon_name ("notification-symbolic", Gtk.IconSize.BUTTON);
            icon_silent = new Gtk.Image.from_icon_name ("notification-disabled-symbolic", Gtk.IconSize.BUTTON);

            notify_button = new Gtk.Button ();
            notify_symbol ();
            notify_button.tooltip_text = _ ("Notify");
            notify_button.clicked.connect (() => {
                settings.notify_switch ();
            });

            open_button =  new Button.from_icon_name ("folder-open-symbolic", IconSize.SMALL_TOOLBAR);
            open_button.tooltip_text = _("Open location");
            open_button.clicked.connect (() => {
            if (!converter.is_running) {
                costum_location ();
                }
            });

            choose_revealer = new Gtk.Revealer ();
            choose_revealer.add (open_button);
            choose_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;

            close_button = new Button.from_icon_name ("window-close-symbolic", IconSize.SMALL_TOOLBAR);
            close_button.tooltip_text = _("Close");
            close_button.clicked.connect (() => {
                signal_close ();
            });

		    settings.notify["youtube-mode"].connect (() => {
            youtube_symbol ();
		    });

            icon_pc = new Gtk.Image.from_icon_name ("computer-symbolic", Gtk.IconSize.BUTTON);
            icon_youtube = new Gtk.Image.from_icon_name ("camera-video-symbolic", Gtk.IconSize.BUTTON);

            youtube_button = new Button ();
            youtube_symbol ();
            youtube_button.tooltip_text = _("Mode");
            youtube_button.clicked.connect (() => {
            if (!converter.is_running) {
                settings.youtube_switch ();
            }
            });

            var headerbar = new Gtk.HeaderBar ();
            headerbar.title = "Mindi";
            headerbar.has_subtitle = false;
            headerbar.show_close_button = false;
            headerbar.pack_end (light_dark_button);
            headerbar.pack_end (notify_button);
            headerbar.pack_start (close_button);
            headerbar.pack_start (location_button);
            headerbar.pack_start (choose_revealer);
            headerbar.pack_start (youtube_button);
            set_titlebar (headerbar);

            var header_context = headerbar.get_style_context ();
            header_context.add_class ("default-decoration");
            header_context.add_class (Gtk.STYLE_CLASS_FLAT);

            var style_context = get_style_context ();
            style_context.add_class ("rounded");
            style_context.add_class ("widget_background");
            style_context.add_class ("flat");

            build_ui();

            converter = ObjectConverter.instance;
            converter.begin.connect (on_converter_started);

            show_all();
        }

        void build_ui () {
            content = new Gtk.Grid ();
            content.margin = 20;
            content.column_spacing = 25;
            content.column_homogeneous = true;
            content.row_spacing = 20;
            content.halign = Gtk.Align.CENTER;
            content.valign = Gtk.Align.CENTER;

            app_notification = new Mindi.Widgets.Toast ("");
            var overlay = new Gtk.Overlay ();
            overlay.add (content);
            overlay.add_overlay (app_notification);

            desktop_notification = new Notification (_ ("Finished"));

            build_video_area ();
            build_youtube_area ();
            build_format_area ();
            build_convert_area ();
            stack_video_youtube ();
            add (overlay);
            show_all ();

            button_press_event.connect ((e) => {
                if (e.button == Gdk.BUTTON_PRIMARY) {
                    begin_move_drag ((int) e.button, (int) e.x_root, (int) e.y_root, e.time);
                    return true;
                }
                return false;
            });

            Timeout.add_seconds (1, () => {
                converter.read_name.begin ();
                return false;
            });

            if (selected_formataudio == null) {
                switch (MindiApp.settings.get_enum ("format-audios")) {
                    case 1:
                        selected_formataudio = format_list.get_child_at_index(1) as Mindi.Formataudio;
                        break;
                    case 2:
                        selected_formataudio = format_list.get_child_at_index(2) as Mindi.Formataudio;
                        break;
                    case 3:
                        selected_formataudio = format_list.get_child_at_index(3) as Mindi.Formataudio;
                        break;
                    case 4:
                        selected_formataudio = format_list.get_child_at_index(4) as Mindi.Formataudio;
                        break;
                    case 5:
                        selected_formataudio = format_list.get_child_at_index(5) as Mindi.Formataudio;
                        break;
                    case 6:
                        selected_formataudio = format_list.get_child_at_index(6) as Mindi.Formataudio;
                        break;
                    case 7:
                        selected_formataudio = format_list.get_child_at_index(7) as Mindi.Formataudio;
                        break;
                    case 8:
                        selected_formataudio = format_list.get_child_at_index(8) as Mindi.Formataudio;
                        break;
                    case 9:
                        selected_formataudio = format_list.get_child_at_index(9) as Mindi.Formataudio;
                        break;
                    default:
                        selected_formataudio = format_list.get_child_at_index(0) as Mindi.Formataudio;
                        break;
                }
            }
        }

        public void signal_close () {
            if (converter.is_running) {
                if (dialog == null) {
                    dialog = new Dialog (this);
                    dialog.show_all ();
                    dialog.dialog_cancel_convert.connect (() => {
                        cancel_convert ();
                        converter.finished.connect (() => {
                            Timeout.add_seconds (1, () => {
                                destroy ();
                                return false;
                            });
                        });
                    });
                    dialog.destroy.connect (() => {
                        dialog = null;
                    });
                }
                dialog.present ();
            } else {
                destroy ();
            }
        }

       private void costum_location () {
            var settings = Mindi.Configs.Settings.get_settings ();
            var location = new Gtk.FileChooserDialog (
                _ ("Select a folder."), this, Gtk.FileChooserAction.SELECT_FOLDER,
                _ ("_Cancel"), Gtk.ResponseType.CANCEL,
                _ ("_Open"), Gtk.ResponseType.ACCEPT);

            var folder = new Gtk.FileFilter ();
            folder.add_mime_type ("inode/directory");
            location.set_filter (folder);

            if (location.run () == Gtk.ResponseType.ACCEPT) {
                selected_location = location.get_file ().get_path ();
                settings.output_folder = selected_location;
                status_location ();
            }
            location.destroy ();
        }

        private void status_location () {
            string output_set = MindiApp.settings.get_string ("output-folder");
	        int longchar = output_set.char_count ();
	        if (longchar > 26) {
	            string string_limited = output_set.substring (0, 25 - 0);
                output_name_location.label = ("Location : " + string_limited + "…");
            } else {
                output_name_location.label = ("Location : " + output_set);
            }
            ask_location.label = ("<i>Where you want to save the audio file</i>");

            Timeout.add_seconds (0,() => {
                output_name_location.set_uri ("file://"+ output_set);
                return false;
            });
        }

        private void build_video_area () {
            video_container = new Gtk.Grid ();
            video_container.row_spacing = 10;
            video_container.width_request = 16;
            video_container.column_homogeneous = true;

            title_video = new Gtk.Label (_ ("A / V"));
            title_video.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            title_video.hexpand = true;
            video_container.attach (title_video, 0, 0, 1, 1);

            video_logo = new Image ();
            video_icon = new ThemedIcon ("applications-multimedia");
            video_container.attach (video_logo, 0, 1, 1, 1);

            video_name = new Gtk.Label ("<i>Choose a video file…</i>");
            video_name.max_width_chars = 16;
            video_name.use_markup = true;
            video_name.ellipsize = Pango.EllipsizeMode.END;
            video_name.halign = Gtk.Align.CENTER;
            video_name.wrap = true;
            video_container.attach (video_name, 0, 2, 1, 1);

            open_video = new Gtk.Button.with_label (_ ("Select Video"));
            open_video.clicked.connect (select_video);
            video_container.attach (open_video, 0, 3, 1, 1);
        }

        private void build_youtube_area () {
            youtube_container = new Gtk.Grid ();
            youtube_container.row_spacing = 10;
            youtube_container.width_request = 16;
            youtube_container.column_homogeneous = true;

            var title_youtube = new Gtk.Label ("Youtube");
            title_youtube.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            title_youtube.hexpand = true;
            youtube_container.attach (title_youtube, 0, 0, 1, 1);

            youtube_logo = new Image.from_icon_name ("com.github.torikulhabib.mindi.youtube", Gtk.IconSize.DIALOG);
            youtube_container.attach (youtube_logo, 0, 1, 1, 1);

            youtube_name = new Gtk.Label ("Download now…");
            youtube_name.max_width_chars = 16;
            youtube_name.ellipsize = Pango.EllipsizeMode.END;
            youtube_name.halign = Gtk.Align.CENTER;
            youtube_name.wrap = true;
            youtube_name.show ();
            youtube_container.attach (youtube_name, 0, 2, 1, 1);

            var button = new Button.from_icon_name ("list-add-symbolic", IconSize.SMALL_TOOLBAR);
            button.tooltip_text = _("Add");
            var clip_button = new Button.from_icon_name ("edit-paste-symbolic", IconSize.SMALL_TOOLBAR);
            clip_button.tooltip_text = _("Paste");
            entry = new Gtk.Entry ();
            entry.tooltip_text = _("Paste URL here…");

            var youtube_grid = new Gtk.Grid ();
            youtube_grid.orientation = Gtk.Orientation.HORIZONTAL;
            youtube_grid.row_spacing = 10;
            youtube_grid.column_spacing = 10;
            youtube_grid.border_width = 10;
            youtube_grid.add (entry);
            youtube_grid.add (clip_button);
            youtube_grid.add (button);
            youtube_grid.show_all ();
            entry.has_focus = true;

            clip_button.clicked.connect (() => {
                Gdk.Display display = get_display ();
                Gtk.Clipboard clipboard = Gtk.Clipboard.get_for_display (display, Gdk.SELECTION_CLIPBOARD);
                string text = clipboard.wait_for_text ().strip ();
                entry.set_text (text);
            });

            button.clicked.connect (() => {
                add_url_clicked ();
                add_url_popover.hide ();
            });

            open_youtube = new Gtk.Button.with_label (_ ("Add URL"));
            open_youtube.valign = Gtk.Align.END;
            open_youtube.clicked.connect (() => {
                    add_url_popover.visible = !add_url_popover.visible;
            });

            add_url_popover = new Gtk.Popover (open_youtube);
            add_url_popover.position = Gtk.PositionType.TOP;
            add_url_popover.add (youtube_grid);

            youtube_container.attach (open_youtube, 0, 3, 1, 1);
        }

        private void stack_video_youtube () {
            youtube_stack = new Stack ();
            youtube_stack.add_named (video_container, "video");
            youtube_stack.add_named (youtube_container, "youtube");
            content.attach (youtube_stack, 0, 0, 1, 1);
        }

        private void add_url_clicked () {
            string url = entry.get_text().strip ();
            bool list = url.contains ("list");
            if (list) {
                string [] link = url.split ("&");
                string result = link [0];
                add_download (result);
                entry.set_text ("");
            } else {
                add_download (url);
                entry.set_text ("");
            }
        }

        private void add_download (string url) {
            if (!converter.is_running) {
                converter.finished.connect (on_converter_finished);
                converter.finished.connect (notify_signal);
                converter.get_video.begin (url);
            }
        }

        private void select_video () {
            var file = new Gtk.FileChooserDialog (
                _ ("Open"), this, Gtk.FileChooserAction.OPEN,
                _ ("_Cancel"), Gtk.ResponseType.CANCEL,
                _ ("_Open"), Gtk.ResponseType.ACCEPT);

            var all_files_filter = new Gtk.FileFilter ();
            all_files_filter.set_filter_name (_("All files"));
            all_files_filter.add_pattern ("*");
            var video_filter = new Gtk.FileFilter ();
            video_filter.set_filter_name (_ ("Video files"));
            video_filter.add_mime_type ("video/mpeg;");
            video_filter.add_mime_type ("video/mp4");
            video_filter.add_mime_type ("video/webm");
            video_filter.add_mime_type ("video/flv");
            var audio_filter = new Gtk.FileFilter ();
            audio_filter.set_filter_name (_ ("Audio files"));
            audio_filter.add_mime_type ("audio/mp3");
            audio_filter.add_mime_type ("audio/wav");
            audio_filter.add_mime_type ("audio/m4a");

            file.add_filter (video_filter);
            file.add_filter (audio_filter);
            file.add_filter (all_files_filter);

            if (file.run () == Gtk.ResponseType.ACCEPT) {
                selected_video = file.get_file ();
                input_find_location ();
            }
            file.destroy ();
        }

        private void input_find_location () {
            var settings = Mindi.Configs.Settings.get_settings ();
            string input = selected_video.get_basename ();
            string video = selected_video.get_path ();
            string [] output = video.split (input);
            string result = output [0];
            settings.folder_link = result;
            set_link =  MindiApp.settings.get_string ("folder-link");
	        int link_longchar = set_link.char_count ();
	        if (link_longchar > 26) {
	            string string_limit = set_link.substring (0, 25 - 0);
                output_name.label = ("Location : " + string_limit + "…");
            } else {
                output_name.label = ("Location : " + set_link);
            }
            Timeout.add_seconds (0,() => {
            output_name.set_uri ("file://" + set_link);
                return false;
            });
            input_type ();
        }

        private void input_type () {
            string input_video = selected_video.get_basename ();
	        int i = input_video.last_index_of (".");
            string out_last = input_video.substring (i + 1);
            string up = out_last.up ();
            if (up.contains ("MP4")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.mp4");
                title_video.label = ("Video");
            } else if (up.contains ("FLV")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.flv");
                title_video.label = ("Video");
            } else if (up.contains ("WEBM")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.webm");
                title_video.label = ("Video");
            } else if (up.contains ("AVI")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.avi");
                title_video.label = ("Video");
            } else if (up.contains ("MPG")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.mpg");
                title_video.label = ("Video");
            } else if (up.contains ("MPEG")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.mpeg");
                title_video.label = ("Video");
            } else if (up.contains ("MKV")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.mkv");
                title_video.label = ("Video");
            } else if (up.contains ("AAC")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.aac");
                title_video.label = ("Audio");
            } else if (up.contains ("AC3")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.ac3");
                title_video.label = ("Audio");
            } else if (up.contains ("AIFF")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.aiff");
                title_video.label = ("Audio");
            } else if (up.contains ("FLAC")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.flac");
                title_video.label = ("Audio");
            } else if (up.contains ("MMF")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.mmf");
                title_video.label = ("Audio");
            } else if (up.contains ("MP3")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.mp3");
                title_video.label = ("Audio");
            } else if (up.contains ("M4A")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.m4a");
                title_video.label = ("Audio");
            } else if (up.contains ("OGG")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.ogg");
                title_video.label = ("Audio");
            } else if (up.contains ("WMA")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.wma");
                title_video.label = ("Audio");
            } else if (up.contains ("WAV")) {
                video_icon = new ThemedIcon ("com.github.torikulhabib.mindi.wav");
                title_video.label = ("Audio");
            } else {
                video_icon = new ThemedIcon ("applications-multimedia");
                title_video.label = ("A / V");
            }
        }

        private void build_format_area () {
            format_container = new Gtk.Grid ();
            format_container.row_spacing = 10;
            format_container.width_request = 16;
            format_container.column_homogeneous = true;
            format_container.sensitive = false;

            var title = new Gtk.Label (_ ("Audio"));
            title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            title.hexpand = true;
            format_container.attach (title, 0, 0, 1, 1);

            var format_grid = new Gtk.Grid ();
            format_list = new Gtk.FlowBox ();
            format_list.child_activated.connect (on_select_fileformat);
            format_grid.add (format_list);

            format_logo = new Gtk.Image ();
            format_container.attach (format_logo, 0, 1, 1, 1);

            format_name = new Gtk.Label (("<i>%s</i>").printf (_ ("")));
            format_name.use_markup = true;
            format_container.attach (format_name, 0, 2, 1, 1);

            select_format = new Gtk.Button.with_label (_ ("Select"));
            select_format.valign = Gtk.Align.END;
            select_format.vexpand = true;
            select_format.clicked.connect (
                () => {
                    format_popover.visible = !format_popover.visible;
                });
            format_container.attach (select_format, 0, 3, 1, 1);

            format_popover = new Gtk.Popover (select_format);
            format_popover.position = Gtk.PositionType.TOP;
            format_popover.add (format_grid);
            format_popover.show.connect (() => {
                if (selected_formataudio != null) {
                    format_list.select_child (selected_formataudio);
                }
                selected_formataudio.grab_focus ();
            });

            foreach (var formataudio in Mindi.Formataudios.get_all ()) {
                var item = new Mindi.Formataudio (formataudio);
                format_list.add (item);
            }

            format_grid.show_all ();
            content.attach (format_container, 1, 0, 1, 1);
        }

        private void on_select_fileformat (Gtk.FlowBoxChild item) {
            selected_formataudio = item as Mindi.Formataudio;
            format_popover.hide ();
        }

        private void build_convert_area () {
            convert_container = new Gtk.Grid ();
            convert_container.row_spacing = 10;
            convert_container.width_request = 16;
            convert_container.column_homogeneous = true;
            convert_container.sensitive = false;

            convert_label = new Gtk.Label ("<i>No Video file choosen…</i>");
            convert_label.use_markup = true;
            convert_label.vexpand = true;
            convert_container.attach (convert_label, 0, 0, 2, 1);

            progressbar_revealer = new Gtk.Revealer ();
            progressbar_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
            progressbar_revealer.valign = Gtk.Align.CENTER;
            convert_container.attach (progressbar_revealer, 0, 0, 2, 1);
            convert_start = new Gtk.Button.with_label (_ ("Convert"));
            convert_start.vexpand = true;
            convert_start.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            convert_start.clicked.connect (convert_video);

            convert_revealer = new Gtk.Revealer ();
            convert_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            convert_revealer.add (convert_start);
            convert_revealer.valign = Gtk.Align.CENTER;
            convert_container.attach (convert_revealer, 0, 4, 2,1);
            convert_revealer.set_reveal_child (true);

            convert_cancel = new Gtk.Button.with_label (_ ("Cancel"));
            convert_cancel.vexpand = true;
            convert_cancel.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            convert_cancel.clicked.connect (() => {
                if (dialog == null) {
                    dialog = new Dialog (this);
                    dialog.show_all ();
                    dialog.dialog_cancel_convert.connect ( () => {
                        cancel_convert ();
                        });
                    dialog.destroy.connect (() => {
                    dialog = null;
                        });
                }
                dialog.present ();
            });

            cancel_revealer = new Gtk.Revealer ();
            cancel_revealer.add (convert_cancel);
            cancel_revealer.valign = Gtk.Align.CENTER;
            cancel_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            convert_container.attach (cancel_revealer, 0, 4, 2,1);

            output_name = new Gtk.LinkButton (_("Location input"));
            output_name.valign = Gtk.Align.CENTER;

            output_name_location = new Gtk.LinkButton (_("Selected audio location"));
            output_name_location.valign = Gtk.Align.CENTER;

            ask_location = new Gtk.Label ("<i>Where you save the audio file</i>");
            ask_location.ellipsize = Pango.EllipsizeMode.END;
            ask_location.max_width_chars = 16;
            ask_location.use_markup = true;
            ask_location.valign = Gtk.Align.CENTER;
            ask_location.wrap = true;

            var label_download = new Gtk.Label ("<i>Downloading…</i>");
            label_download.use_markup = true;
            label_download.valign = Gtk.Align.CENTER;

            stack = new Stack ();
            stack.add_named (output_name, "name");
            stack.add_named (output_name_location, "name_custom");
            stack.add_named (ask_location, "ask");
            stack.add_named (label_download, "download");
            convert_container.attach (stack, 0, 3, 2, 1);

            content.attach (convert_container, 0, 1, 2, 1);
        }

        private void on_converter_started (bool now_converting) {
            string ask_location_set =  MindiApp.settings.get_string ("ask-location");
            ask_location.label = ("Location : " + ask_location_set);

            open_video.sensitive = false;
            open_youtube.sensitive = false;
            video_name.sensitive = false;
            video_logo.sensitive = false;
            select_format.sensitive = false;
            format_logo.sensitive = false;
            format_name.sensitive = false;
            convert_start.sensitive = false;
            youtube_logo.sensitive = false;

            convert_revealer.visible = false;
            convert_revealer.set_reveal_child (false);
            cancel_revealer.set_reveal_child (true);
            progressbar_revealer.add (converter);

            Timeout.add_seconds (1, () => {
            progressbar_revealer.set_reveal_child (true);
            convert_label.visible = false;
                return false;
            });
            if (youtube_active) {
            convert_container.sensitive = true;
            format_container.sensitive = true;
                if (!now_converting) {
                    Timeout.add_seconds (0,() => {
                        stack.visible_child_name = "download";
                        youtube_name.label = "Please wait…";
                        return false;
                    });
                }
            }
        }

        private void on_converter_finished (bool success) {
            converter.finished.disconnect (on_converter_finished);
            converter.finished.disconnect (notify_signal);
            progressbar_revealer.remove (converter);
            folder_symbol ();
            ask_location.label = ("<i>Where you want to save the audio file</i>");

            Timeout.add_seconds (1, () => {
            convert_revealer.set_reveal_child (true);
            convert_revealer.visible = true;
            cancel_revealer.set_reveal_child (false);
            progressbar_revealer.set_reveal_child (false);
            convert_label.visible = true;
                return false;
            });

            open_video.sensitive = true;
            open_youtube.sensitive = true;
            video_name.sensitive = true;
            video_logo.sensitive = true;
            select_format.sensitive = true;
            format_logo.sensitive = true;
            format_name.sensitive = true;
            convert_start.sensitive = true;
            youtube_logo.sensitive = true;

            if (youtube_active) {
                if (converter.is_downloading){
                    status_location ();
                    if (success) {
                        Timeout.add_seconds (0, () => {
                            converter.read_name.begin ();
                            youtube_name.label = converter.name_file_stream;
                            return false;
                        });

                        app_notification.title = "Download succes";
                        convert_label.label = ("Ready to convert!");
                        app_notification.send_notification ();
                        convert_start.sensitive = true;
                        select_format.sensitive = true;
                    } else {
                        app_notification.title = "Download Error";
                        app_notification.send_notification ();
                        youtube_name.label = ("Failed retrieve…");
                        convert_label.label = ("<i>Not ready yet!</i>");
                        convert_start.sensitive = false;
                        select_format.sensitive = true;
                    }
                } else {
                    if (success) {
                        message = _("%s was converted into %s").printf (converter.name_file_stream, selected_formataudio.formataudio.get_name ());
                    } else {
                        message = _("%s Error while convert into %s").printf (converter.name_file_stream, selected_formataudio.formataudio.get_name ());
                    }
                    notify_signal (success);
                }
            } else {
                if (success) {
                    message = _("%s was converted into %s").printf (selected_video.get_basename (), selected_formataudio.formataudio.get_name ());
                } else {
                    message = _("%s Error while convert into %s").printf (selected_video.get_basename (), selected_formataudio.formataudio.get_name ());
                    }
                notify_signal (success);
                }
        }

        private void notify_signal (bool success) {
            if (is_active) {
                if (success) {
                    if (notify_active) {
                        create_dialog_finish (_("%s").printf (message));
                    } else {
                        app_notification.title = "Finished";
                        app_notification.send_notification ();
                    }
                } else {
                    if (notify_active) {
                        create_dialog_error (_("%s").printf (message));
                    } else {
                        app_notification.title = "Error";
                        app_notification.send_notification ();
                    }
                    fail_convert ();
                }
            } else {
                if (success) {
                    desktop_notification.set_title (_("Finished"));
                } else {
                    desktop_notification.set_title (_("Error"));
                    fail_convert ();
                }
                if (notify_active) {
                    desktop_notification.set_body (message);
                    application.send_notification ("notify.app", desktop_notification);
                }
            }
        }

        private void create_dialog_finish (string text) {
            var message_dialog = new Mindi.MessageDialog.with_image_from_icon_name (this, "Finished",text,"com.github.torikulhabib.mindi",
 Gtk.ButtonsType.CLOSE);
            var auto_close = new Gtk.CheckButton.with_label ("Automatic Close");
            auto_close.show ();
            auto_close.toggled.connect (() => {
            Timeout.add_seconds (1, () => {
            message_dialog.destroy ();
                return false;
            });
            });
            message_dialog.custom_bin.add (auto_close);
            MindiApp.settings.bind ("auto-close", auto_close, "active", GLib.SettingsBindFlags.DEFAULT);
            message_dialog.run ();
            message_dialog.destroy ();
        }

        private void create_dialog_error (string text) {
            var message_dialog = new Mindi.MessageDialog.with_image_from_icon_name (this, "Error",text,"com.github.torikulhabib.mindi",
 Gtk.ButtonsType.CLOSE);
            var auto_close = new Gtk.CheckButton.with_label ("Automatic Close");
            auto_close.show ();
            auto_close.toggled.connect (() => {
            Timeout.add_seconds (1, () => {
            message_dialog.destroy ();
                return false;
            });
            });
            message_dialog.custom_bin.add (auto_close);
            MindiApp.settings.bind ("auto-close", auto_close, "active", GLib.SettingsBindFlags.DEFAULT);
            message_dialog.run ();
            message_dialog.destroy ();
        }

       private void ask_costum_location () {
            var settings = Mindi.Configs.Settings.get_settings ();
            var ask_location = new Gtk.FileChooserDialog (
                _ ("Select a folder."), this, Gtk.FileChooserAction.SELECT_FOLDER,
                _ ("_Cancel"), Gtk.ResponseType.CANCEL,
                _ ("_Open"), Gtk.ResponseType.ACCEPT);

            var folder_ask = new Gtk.FileFilter ();
            folder_ask.add_mime_type ("inode/directory");
            ask_location.set_filter (folder_ask);

            if (ask_location.run () == Gtk.ResponseType.ACCEPT) {
                ask_location_folder = ask_location.get_file ().get_path ();
                settings.ask_location = ask_location_folder;
                converter.finished.connect (on_converter_finished);
                converter.finished.connect (notify_signal);
                converter.set_folder.begin (selected_video, youtube_active);
                converter.converter_now.begin (selected_formataudio.formataudio);
            }
            ask_location.destroy ();
        }

        private void convert_video () {
            if (!converter.is_running) {
                if (ask_active) {
                    ask_costum_location ();
                } else {
                    converter.finished.connect (on_converter_finished);
                    converter.finished.connect (notify_signal);
                    converter.set_folder.begin (selected_video, youtube_active);
                    converter.converter_now.begin (selected_formataudio.formataudio);
                }
            }
        }

        private void cancel_convert () {
            if (converter.is_running) {
                converter.cancel_now.begin ();
            }
        }

        private void fail_convert () {
            if (!converter.is_running) {
                converter.set_folder.begin (selected_video, youtube_active);
                converter.remove_failed.begin (selected_formataudio.formataudio);
            }
        }

        private void update_formataudio_label () {
            var settings = Mindi.Configs.Settings.get_settings ();
            settings.update_formataudio (selected_formataudio.formataudio);
            switch (selected_formataudio.formataudio) {
                case Mindi.Formataudios.AC3:
                    format_icon = new ThemedIcon ("com.github.torikulhabib.mindi.ac3");
                    break;
                case Mindi.Formataudios.AIFF:
                    format_icon = new ThemedIcon ("com.github.torikulhabib.mindi.aiff");
                    break;
                case Mindi.Formataudios.FLAC:
                    format_icon = new ThemedIcon ("com.github.torikulhabib.mindi.flac");
                    break;
                case Mindi.Formataudios.MMF:
                    format_icon = new ThemedIcon ("com.github.torikulhabib.mindi.mmf");
                    break;
                case Mindi.Formataudios.MP3:
                    format_icon = new ThemedIcon ("com.github.torikulhabib.mindi.mp3");
                    break;
                case Mindi.Formataudios.M4A:
                    format_icon = new ThemedIcon ("com.github.torikulhabib.mindi.m4a");
                    break;
                case Mindi.Formataudios.OGG:
                    format_icon = new ThemedIcon ("com.github.torikulhabib.mindi.ogg");
                    break;
                case Mindi.Formataudios.WMA:
                    format_icon = new ThemedIcon ("com.github.torikulhabib.mindi.wma");
                    break;
                case Mindi.Formataudios.WAV:
                    format_icon = new ThemedIcon ("com.github.torikulhabib.mindi.wav");
                    break;
                default:
                    format_icon = new ThemedIcon ("com.github.torikulhabib.mindi.aac");
                    break;
            }
        }

        private void light_dark_symbol () {
            var settings = Mindi.Configs.Settings.get_settings ();
            switch (settings.light_mode) {
                case LightMode.LIGHT :
                    light_dark_button.set_image (icon_light);
                    Gtk.Settings.get_default().gtk_application_prefer_dark_theme = false;
                    break;
                case LightMode.DARK :
                    light_dark_button.set_image (icon_dark);
                    Gtk.Settings.get_default().gtk_application_prefer_dark_theme = true;
                    break;
                }
                   light_dark_button.show_all ();
            }

        private void notify_symbol () {
            var settings = Mindi.Configs.Settings.get_settings ();
            switch (settings.notify_mode) {
                case NotifyMode.NOTIFY :
                    notify_button.set_image (icon_notify);
                    notify_active = true;
                    break;
                case NotifyMode.SILENT :
                    notify_button.set_image (icon_silent);
                    notify_active = false;
                    break;
                }
                   notify_button.show_all ();
            }

        private void youtube_symbol () {
            var settings = Mindi.Configs.Settings.get_settings ();
            switch (settings.youtube_mode) {
                case YoutubeMode.PC :
                    youtube_button.set_image (icon_pc);
                    youtube_active = false;
                    Timeout.add_seconds (0,() => {
                        youtube_stack.visible_child_name = "video";
                        return false;
                    });
                    break;
                case YoutubeMode.YOUTUBE :
                    youtube_button.set_image (icon_youtube);
                    youtube_active = true;
                    Timeout.add_seconds (0,() => {
                        youtube_stack.visible_child_name = "youtube";
                        return false;
                    });
                    break;
            }
                   youtube_button.show_all ();
        }

        private void folder_symbol () {
            var settings = Mindi.Configs.Settings.get_settings ();
            switch (settings.folder_mode) {
                case FolderMode.PLACE :
                    location_button.set_image (icon_folder_open);
                    ask_active = false;
                    Timeout.add_seconds (0,() => {
                        choose_revealer.set_reveal_child (false);
                        stack.visible_child_name = "name";
                        return false;
                    });
                    break;
                case FolderMode.CUSTOM :
                    location_button.set_image (icon_folder);
                    ask_active = false;
                    Timeout.add_seconds (0,() => {
                        choose_revealer.set_reveal_child (true);
                        stack.visible_child_name = "name_custom";
                        return false;
                    });
                    break;
                case FolderMode.ASK :
                    location_button.set_image (ask_icon_folder);
                    ask_active = true;
                    Timeout.add_seconds (0,() => {
                        choose_revealer.set_reveal_child (false);
                        stack.visible_child_name = "ask";
                        return false;
                    });
                    break;
            }
            location_button.show_all ();
        }
    }
}
