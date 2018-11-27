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
        private Grid video_container;

        private Button select_format;
        private Popover format_popover;
        private Image format_logo;
        private FlowBox format_list;
        private Label format_name;
        private Grid format_container;

        private Image convert_logo;
        private Grid convert_container;
        private Label convert_label;
        private Button convert_start;
        private Button convert_cancel;

        private Button close_button;
        private Label output_name;
        private Label output_name_location;
        private Label ask_location;

        private Revealer choose_revealer;
        private Revealer convert_revealer;
        private Revealer cancel_revealer;
        private Revealer progressbar_revealer;
        private Revealer find_revealer;

        private Image ask_icon_folder;
        private Image icon_folder_open;
        private Image icon_folder;
        private Image icon_notify;
        private Image icon_silent;
        private Button notify_button;
        private Button open_button;
        private Button location_button;
        private Button find_button;
        private Stack stack;

        private string selected_location;
        private string ask_location_folder;
        private string link_set;
        private string set_link;
        private bool notify_set {get;set;}
        private bool folder_set {get;set;}
        private bool ask_set {get;set;}

        Notification desktop_notification;
        Mindi.Widgets.Toast app_notification;

        private GLib.Icon image_icon { 
            owned get {
                return format_logo.gicon;
            }
            set {
                format_logo.set_from_gicon (value, Gtk.IconSize.DIALOG);
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
                    set_video_label (selected_video.get_basename ());
                    open_video.label = _ ("Change");
                    status_location ();
                    input_find_folder ();
                } else {
                    set_video_label ("");
                    audio_output_label ("");
                    audio_output_label_loction ("");
                    open_video.label = _ ("Open");
                }
            set_convert_label ();
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
            var gtk_settings = Gtk.Settings.get_default ();
            var mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic");
            mode_switch.primary_icon_tooltip_text = _("Light background");
            mode_switch.secondary_icon_tooltip_text = _("Dark background");
            mode_switch.valign = Gtk.Align.CENTER;
            mode_switch.bind_property ("active", gtk_settings, "gtk_application_prefer_dark_theme");

            MindiApp.settings.bind ("prefer-dark-style", mode_switch, "active", GLib.SettingsBindFlags.DEFAULT);

            var settings = Mindi.Configs.Settings.get_settings ();
		    settings.notify["folder-mode"].connect (() => {
            folder_symbol ();
		    });

            icon_folder_open = new Gtk.Image.from_icon_name ("document-save-symbolic", Gtk.IconSize.BUTTON);
            icon_folder = new Gtk.Image.from_icon_name ("document-save-as-symbolic", Gtk.IconSize.BUTTON);
            ask_icon_folder = new Gtk.Image.from_icon_name ("system-help-symbolic", Gtk.IconSize.BUTTON);

            location_button = new Gtk.Button ();
            folder_symbol ();
            location_button.tooltip_text = _ ("Location");
            location_button.can_focus = false;
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
            notify_button.can_focus = false;
            notify_button.clicked.connect (() => {
                settings.notify_switch ();
            });

            open_button =  new Button.from_icon_name ("folder-open-symbolic", IconSize.SMALL_TOOLBAR);
            open_button.tooltip_text = _("Open custom folder");
            open_button.can_focus = false;
            open_button.clicked.connect (() => {
            select_audio_place ();
            });

            choose_revealer = new Gtk.Revealer ();
            choose_revealer.add (open_button);
            choose_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;

            close_button = new Button.from_icon_name ("window-close-symbolic", IconSize.SMALL_TOOLBAR);
            close_button.vexpand = true;
            close_button.tooltip_text = _("Close");
            close_button.clicked.connect (() => {
                signal_close ();
            });

            find_button = new Button.from_icon_name ("folder-saved-search-symbolic", IconSize.SMALL_TOOLBAR);
            find_button.vexpand = true;
            find_button.tooltip_text = _("Find Folder");
            find_button.clicked.connect (() => {
                if (folder_set == false) {
                    link_set =  MindiApp.settings.get_string ("output-folder");
                    open_folder_file_app (link_set);
                    } else {
                    set_link =  MindiApp.settings.get_string ("folder-link");
                    open_folder_file (set_link);
                }
            });

            find_revealer = new Gtk.Revealer ();
            find_revealer.add (find_button);
            find_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;

            var headerbar = new Gtk.HeaderBar ();
            headerbar.title = "Mindi";
            headerbar.has_subtitle = false;
            headerbar.show_close_button = false;
            headerbar.pack_end (mode_switch);
            headerbar.pack_end (notify_button);
            headerbar.pack_start (close_button);
            headerbar.pack_start (location_button);
            headerbar.pack_start (choose_revealer);
            headerbar.pack_start (find_revealer);
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
            build_format_area ();
            build_convert_area ();

            add (overlay);
            show_all ();

            button_press_event.connect ((e) => {
                if (e.button == Gdk.BUTTON_PRIMARY) {
                    begin_move_drag ((int) e.button, (int) e.x_root, (int) e.y_root, e.time);
                    return true;
                }
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

        public static void open_folder_file_app (string link_set) {
            try {
                var directory = File.new_for_path (link_set);
                AppInfo.launch_default_for_uri (directory.get_uri(), null);
            } catch (Error e) {
                GLib.critical (e.message);
            }
        }

        public static void open_folder_file (string set_link) {
            try {
                var directory = File.new_for_path (set_link);
                AppInfo.launch_default_for_uri (directory.get_uri(), null);
            } catch (Error e) {
                GLib.critical (e.message);
            }
        }

       private void select_audio_place () {
            var settings = Mindi.Configs.Settings.get_settings ();
            var location = new Gtk.FileChooserDialog (
                _ ("Select a folder."), this, Gtk.FileChooserAction.SELECT_FOLDER,
                _ ("_Cancel"), Gtk.ResponseType.CANCEL,
                _ ("_Open"), Gtk.ResponseType.ACCEPT);

            var folder = new Gtk.FileFilter ();
            folder.set_filter_name (_ ("Folder"));
            folder.add_mime_type ("inode/directory");

            location.add_filter (folder);

            if (location.run () == Gtk.ResponseType.ACCEPT) {
                selected_location = location.get_file ().get_path ();
            }

            location.destroy ();
            settings.output_folder = selected_location;
            status_location ();
        }

        private void build_video_area () {
            video_container = new Gtk.Grid ();
            video_container.row_spacing = 10;
            video_container.width_request = 16;
            video_container.column_homogeneous = true;

            var title = new Gtk.Label (_ ("Video"));
            title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            title.hexpand = true;
            video_container.attach (title, 0, 0, 1, 1);

            video_logo = new Image.from_icon_name ("applications-multimedia", Gtk.IconSize.DIALOG);
            video_container.attach (video_logo, 0, 1, 1, 1);
            video_name = new Gtk.Label ("");
            video_name.max_width_chars = 16;
            video_name.use_markup = true;
            video_name.ellipsize = Pango.EllipsizeMode.END;
            video_name.halign = Gtk.Align.CENTER;
            video_name.wrap = true;
            set_video_label ("");
            video_container.attach (video_name, 0, 2, 1, 1);

            open_video = new Gtk.Button.with_label (_ ("Select Video"));
            open_video.clicked.connect (select_video);
            video_container.attach (open_video, 0, 3, 1, 1);

            content.attach (video_container, 0, 0, 1, 1);
        }

        private void set_video_label (string text) {
            if (text != "") {
                video_name.label = text;
            } else {
                video_name.label = ("<i>%s</i>").printf (_ ("Choose a video file…"));
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
            }

            file.destroy ();
            input_find_folder ();
        }

        private void status_location () {
            string output_set =  MindiApp.settings.get_string ("output-folder");
            audio_output_label ("Location : " + selected_video.get_path ());
            audio_output_label_loction ("Location : " + output_set);
        }

        private void input_find_folder () {
            var settings = Mindi.Configs.Settings.get_settings ();
            string input = selected_video.get_basename ();
            string video = selected_video.get_path ();
            string [] output = video.split (input);
            string result = output [0];
            settings.folder_link = result;
        }

        private void build_format_area () {
            format_container = new Gtk.Grid ();
            format_container.sensitive = false;
            format_container.row_spacing = 10;
            format_container.width_request = 16;
            format_container.column_homogeneous = true;
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
            format_popover.visible = false;
        }

        private void build_convert_area () {
            convert_container = new Gtk.Grid ();
            convert_container.row_spacing = 10;
            convert_container.sensitive = false;
            convert_container.width_request = 16;
            convert_container.column_homogeneous = true;

            progressbar_revealer = new Gtk.Revealer ();
            progressbar_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
            progressbar_revealer.valign = Gtk.Align.CENTER;
            convert_container.attach (progressbar_revealer, 0, 0, 2, 1);
            progressbar_revealer.remove (converter);
            convert_start = new Gtk.Button.with_label (_ ("Convert"));
            convert_start.vexpand = true;
            convert_start.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            convert_start.clicked.connect (convert_video);

            convert_label = new Gtk.Label ("");
            convert_label.use_markup = true;
            convert_label.vexpand = true;
            set_convert_label ();
            convert_container.attach (convert_label, 0, 0, 2, 1);

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

            output_name = new Gtk.Label ("");
            output_name.max_width_chars = 16;
            output_name.use_markup = true;
            output_name.ellipsize = Pango.EllipsizeMode.END;
            output_name.valign = Gtk.Align.CENTER;
            output_name.wrap = true;
            audio_output_label ("");

            output_name_location = new Gtk.Label ("");
            output_name_location.max_width_chars = 16;
            output_name_location.use_markup = true;
            output_name_location.ellipsize = Pango.EllipsizeMode.END;
            output_name_location.valign = Gtk.Align.CENTER;
            output_name_location.wrap = true;
            audio_output_label_loction ("");

            ask_location = new Gtk.Label ("");
            ask_location.max_width_chars = 16;
            ask_location.use_markup = true;
            output_name_location.valign = Gtk.Align.CENTER;
            output_name_location.wrap = true;
            ask_audio_output_label_loction ("");

            stack = new Stack ();
            stack.add_named (output_name, "name");
            stack.add_named (output_name_location, "name_custom");
            stack.add_named (ask_location, "ask");
            convert_container.attach (stack, 0, 3, 2, 1);

            content.attach (convert_container, 0, 1, 2, 1);
        }

        private void audio_output_label (string text) {
            if (text != "") {
                output_name.label = text;
            } else {
                output_name.label = ("<i>%s</i>").printf (_ ("Audio folder location"));
            }
        }

        private void audio_output_label_loction (string text) {
            if (text != "") {
                output_name_location.label = text;
            } else {
                output_name_location.label = ("<i>%s</i>").printf (_ ("Audio folder location"));
            }
        }

        private void ask_audio_output_label_loction (string text) {
            if (text != "") {
                ask_location.label = text;
            } else {
                ask_location.label = ("<i>%s</i>").printf (_ ("Where you save the audio file"));
            }
        }

        private void set_convert_label () {
            if (selected_video == null) {
                convert_label.label = ("<i>%s</i>").printf (_ ("No Video file choosen…"));
            } else {
                convert_label.label = _ ("Ready!");
            }
        }

        private void on_converter_started () {
            string output_set =  MindiApp.settings.get_string ("ask-folder");
            ask_audio_output_label_loction ("Location : " + output_set);

            open_video.sensitive = false;
            video_name.sensitive = false;
            video_logo.sensitive = false;
            select_format.sensitive = false;
            format_name.sensitive = false;
            format_logo.sensitive = false;
            convert_start.sensitive = false;
            convert_logo.sensitive = false;

            convert_revealer.visible = false;
            convert_revealer.set_reveal_child (false);
            cancel_revealer.set_reveal_child (true);
            progressbar_revealer.add (converter);

            Timeout.add_seconds (1, () => {
            progressbar_revealer.set_reveal_child (true);
            convert_label.visible = false;
                return false;
            });
        }

        private void on_converter_finished (bool success) {
            converter.finished.disconnect (on_converter_finished);
            progressbar_revealer.remove (converter);

            ask_audio_output_label_loction ("<i>Where you save the audio file</i>");

            Timeout.add_seconds (1, () => {
            convert_revealer.set_reveal_child (true);
            convert_revealer.visible = true;
            cancel_revealer.set_reveal_child (false);
            progressbar_revealer.set_reveal_child (false);
            convert_label.visible = true;
                return false;
            });

            open_video.sensitive = true;
            video_name.sensitive = true;
            video_logo.sensitive = true;
            select_format.sensitive = true;
            format_logo.sensitive = true;
            format_name.sensitive = true;
            convert_logo.sensitive = true;
            convert_start.sensitive = true;

            string message;
            if (success) {
                message = _("%s was converted into %s").printf (selected_video.get_basename (), selected_formataudio.formataudio.get_name ());
            } else {
                message = _("Error while convert %s into %s").printf (selected_video.get_basename (), selected_formataudio.formataudio.get_name ());
            }

            if (is_active) {
                if (success) {
                    if (notify_set == true) {
                        create_dialog_finish (_("%s").printf (message));
                    } else {
                        app_notification.title = "Finished";
                        app_notification.send_notification ();
                    }
                } else {
                    if (notify_set == true) {
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
                if (notify_set == true) {
                    desktop_notification.set_body (message);
                    application.send_notification ("notify.app", desktop_notification);
                }
            }

        }

        private void create_dialog_finish (string text) {
            var message_dialog = new Mindi.MessageDialog.with_image_from_icon_name ("Finished",text,"com.github.torikulhabib.mindi",
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
            var message_dialog = new Mindi.MessageDialog.with_image_from_icon_name ("Error",text,"com.github.torikulhabib.mindi",
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

       private void ask_select_audio_place () {
            var settings = Mindi.Configs.Settings.get_settings ();
            var ask_location = new Gtk.FileChooserDialog (
                _ ("Select a folder."), this, Gtk.FileChooserAction.SELECT_FOLDER,
                _ ("_Cancel"), Gtk.ResponseType.CANCEL,
                _ ("_Open"), Gtk.ResponseType.ACCEPT);

            var folder_ask = new Gtk.FileFilter ();
            folder_ask.set_filter_name (_ ("Folder"));
            folder_ask.add_mime_type ("inode/directory");

            ask_location.add_filter (folder_ask);

            if (ask_location.run () == Gtk.ResponseType.ACCEPT) {
                ask_location_folder = ask_location.get_file ().get_path ();
                settings.ask_folder = ask_location_folder;
                converter.finished.connect (on_converter_finished);
                converter.set_folder.begin (selected_video);
                converter.converter_now.begin (selected_formataudio.formataudio);
            }
            ask_location.destroy ();
        }

        private void convert_video () {
            if (!converter.is_running) {
                if (ask_set == true) {
                    ask_select_audio_place ();
                } else {
                    converter.finished.connect (on_converter_finished);
                    converter.set_folder.begin (selected_video);
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
                converter.set_folder.begin (selected_video);
                converter.remove_failed.begin (selected_formataudio.formataudio);
            }
        }

        private void update_formataudio_label () {
            var settings = Mindi.Configs.Settings.get_settings ();
            settings.update_formataudio (selected_formataudio.formataudio);
            switch (selected_formataudio.formataudio) {
                case Mindi.Formataudios.AC3:
                    image_icon = new ThemedIcon ("com.github.torikulhabib.mindi.ac3");
                    break;
                case Mindi.Formataudios.AIFF:
                    image_icon = new ThemedIcon ("com.github.torikulhabib.mindi.aiff");
                    break;
                case Mindi.Formataudios.FLAC:
                    image_icon = new ThemedIcon ("com.github.torikulhabib.mindi.flac");
                    break;
                case Mindi.Formataudios.MMF:
                    image_icon = new ThemedIcon ("com.github.torikulhabib.mindi.mmf");
                    break;
                case Mindi.Formataudios.MP3:
                    image_icon = new ThemedIcon ("com.github.torikulhabib.mindi.mp3");
                    break;
                case Mindi.Formataudios.M4A:
                    image_icon = new ThemedIcon ("com.github.torikulhabib.mindi.m4a");
                    break;
                case Mindi.Formataudios.OGG:
                    image_icon = new ThemedIcon ("com.github.torikulhabib.mindi.ogg");
                    break;
                case Mindi.Formataudios.WMA:
                    image_icon = new ThemedIcon ("com.github.torikulhabib.mindi.wma");
                    break;
                case Mindi.Formataudios.WAV:
                    image_icon = new ThemedIcon ("com.github.torikulhabib.mindi.wav");
                    break;
                default:
                    image_icon = new ThemedIcon ("com.github.torikulhabib.mindi.aac");
                    break;
            }
        }

        private void notify_symbol () {
                var settings = Mindi.Configs.Settings.get_settings ();
                switch (settings.notify_mode) {
                case NotifyMode.NOTIFY :
                    notify_button.set_image (icon_notify);
                    notify_set = true;
                    break;
                case NotifyMode.SILENT :
                    notify_button.set_image (icon_silent);
                    notify_set = false;
                    break;
                }
                   notify_button.show_all ();
            }

        private void folder_symbol () {
                var settings = Mindi.Configs.Settings.get_settings ();
                switch (settings.folder_mode) {
                case FolderMode.PLACE :
                    location_button.set_image (icon_folder_open);
                    folder_set = true;
                    ask_set = false;
                    Timeout.add_seconds (0, () => {
                        choose_revealer.set_reveal_child (false);
                        find_revealer.set_reveal_child (true);
                    stack.visible_child_name = "name";
                        return false;
                    });
                    break;
                case FolderMode.CUSTOM :
                    location_button.set_image (icon_folder);
                    folder_set = false;
                    ask_set = false;
                    Timeout.add_seconds (0, () => {
                        choose_revealer.set_reveal_child (true);
                        find_revealer.set_reveal_child (true);
                        stack.visible_child_name = "name_custom";
                        return false;
                    });
                    break;
                case FolderMode.ASK :
                    location_button.set_image (ask_icon_folder);
                    folder_set = false;
                    ask_set = true;
                    Timeout.add_seconds (0, () => {
                        choose_revealer.set_reveal_child (false);
                        find_revealer.set_reveal_child (false);
                        stack.visible_child_name = "ask";
                        return false;
                    });
                    break;
                }
                   location_button.show_all ();
            }

    }
}
