using Gtk;

namespace Mindi { 
    public class Window : Gtk.ApplicationWindow {
        Gtk.Grid content;
        Gtk.Button open_video;
        Gtk.Image video_logo;
        Gtk.Label video_name;
        Gtk.Grid video_container;

        Gtk.Button select_format;
        Gtk.Popover format_popover;
        Gtk.Image format_logo;
        Gtk.FlowBox format_list;
        Gtk.Label format_name;
        Gtk.Grid format_container;

        Gtk.Image convert_logo;
        Gtk.Spinner convert;
        Gtk.Grid convert_container;
        Gtk.Label convert_label;
        Gtk.Button convert_start;

        Granite.Widgets.Toast app_notification;
        Notification desktop_notification;

        File _selected_video = null;
        public File selected_video {
            get { return _selected_video; }
            set {
                _selected_video = value;
                this.format_container.sensitive = selected_video != null;
                this.convert_container.sensitive = selected_video != null;

                if (selected_video != null) {
                    this.set_video_label (selected_video.get_basename ());
                    this.open_video.label = _ ("Change");
                } else {
                    this.set_video_label ("");
                    this.open_video.label = _ ("Open");
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

        Mindi.ObjectConverter converter;

        public Window () {
            this.resizable = false;
            this.hexpand = true;
            var gtk_settings = Gtk.Settings.get_default ();
            var mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic");
            mode_switch.primary_icon_tooltip_text = _("Light background");
            mode_switch.secondary_icon_tooltip_text = _("Dark background");
            mode_switch.valign = Gtk.Align.CENTER;
            mode_switch.bind_property ("active", gtk_settings, "gtk_application_prefer_dark_theme");

            MindiApp.settings.bind ("prefer-dark-style", mode_switch, "active", GLib.SettingsBindFlags.DEFAULT);

            var headerbar = new Gtk.HeaderBar ();
            headerbar.title = "Mindi";
            headerbar.get_style_context ().add_class(Gtk.STYLE_CLASS_FLAT);
            headerbar.has_subtitle = false;
            headerbar.show_close_button = true;
            headerbar.pack_end (mode_switch);
            this.set_titlebar (headerbar);

            build_ui();

            converter = ObjectConverter.instance;
            converter.begin.connect (on_converter_started);
            show_all();
            present ();
        }

        void build_ui () {
            content = new Gtk.Grid ();
            content.margin = 32;
            content.column_spacing = 32;
            content.column_homogeneous = true;
            content.row_spacing = 24;

            app_notification = new Granite.Widgets.Toast ("");
            var overlay = new Gtk.Overlay ();
            overlay.add (content);
            overlay.add_overlay (app_notification);

            desktop_notification = new Notification (_ ("Finished"));

            build_video_area ();
            build_format_area ();
            build_convert_area ();

            this.add (overlay);
            this.show_all ();

            if (selected_formataudio == null) {
                selected_formataudio = format_list.get_child_at_index(0) as Mindi.Formataudio;
            }
        }

        private void build_video_area () {
            video_container = new Gtk.Grid ();
            video_container.row_spacing = 24;
            video_container.width_request = 180;

            var title = new Gtk.Label (_ ("Video"));
            title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            title.hexpand = true;
            video_container.attach (title, 0, 0, 1, 1);

            video_logo = new Gtk.Image.from_icon_name ("applications-multimedia", Gtk.IconSize.DIALOG);
            video_container.attach (video_logo, 0, 1, 1, 1);

            open_video = new Gtk.Button.with_label (_ ("Select Video"));
            open_video.clicked.connect (select_video);
            video_container.attach (open_video, 0, 3, 1, 1);

            video_name = new Gtk.Label ("");
            video_name.max_width_chars = 35;
            video_name.use_markup = true;
            video_name.wrap = true;
            set_video_label ("");
            video_container.attach (video_name, 0, 2, 1, 1);
            content.attach (video_container, 0, 0, 1, 1);
        }

        private void set_video_label (string text) {
            if (text != "") {
                this.video_name.label = text;
            } else {
                this.video_name.label = ("<i>%s</i>").printf (_ ("Choose a video file…"));
            }
        }

        private void select_video () {
            var file = new Gtk.FileChooserDialog (
                _ ("Open"), this,
                Gtk.FileChooserAction.OPEN,
                _ ("_Cancel"), Gtk.ResponseType.CANCEL,
                _ ("_Open"), Gtk.ResponseType.ACCEPT);

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

            if (file.run () == Gtk.ResponseType.ACCEPT) {
                selected_video = file.get_file ();
                debug (file.get_filename ());
            }

            file.destroy ();
        }

        private void build_format_area () {
            format_container = new Gtk.Grid ();
            format_container.sensitive = false;
            format_container.row_spacing = 24;
            format_container.width_request = 180;

            var title = new Gtk.Label (_ ("Audio"));
            title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            title.get_style_context ().add_class (Gtk.STYLE_CLASS_LABEL);
            title.hexpand = true;
            format_container.attach (title, 0, 0, 1, 1);

            var format_grid = new Gtk.Grid ();
            format_list = new Gtk.FlowBox ();
            format_list.child_activated.connect (on_select_fileformat);

            format_grid.add (format_list);

            format_logo = new Gtk.Image.from_icon_name ("multimedia-audio-player", Gtk.IconSize.DIALOG);
            format_container.attach (format_logo, 0, 1, 1, 1);

            select_format = new Gtk.Button.with_label (_ ("Select"));
            select_format.valign = Gtk.Align.END;
            select_format.vexpand = true;
            select_format.clicked.connect (
                () => {
                    format_popover.visible = !format_popover.visible;
                });
            format_container.attach (select_format, 0, 3, 1, 1);

            format_name = new Gtk.Label (("<i>%s</i>").printf (_ ("Select Audio")));
            format_name.use_markup = true;
            format_container.attach (format_name, 0, 2, 1, 1);

            format_popover = new Gtk.Popover (select_format);
            format_popover.position = Gtk.PositionType.TOP;
            format_popover.get_style_context ().add_class(Gtk.STYLE_CLASS_POPOVER);
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
            debug ("Selected fileformat: %s", (item as Mindi.Formataudio).formataudio.get_name ());
            selected_formataudio = item as Mindi.Formataudio;
            format_popover.visible = false;
        }

        private void build_convert_area () {
            convert_container = new Gtk.Grid ();
            convert_container.row_spacing = 24;
            convert_container.sensitive = false;
            convert_container.width_request = 180;

            convert = new Gtk.Spinner ();

            var title = new Gtk.Label (_ ("Convert"));
            title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            title.hexpand = true;
            convert_container.attach (title, 0, 0);

            convert_logo = new Gtk.Image.from_icon_name ("media-playback-start", Gtk.IconSize.DIALOG);

            convert_container.attach (convert, 0, 2);
            convert_container.attach (convert_logo, 0, 1);

            convert_start = new Gtk.Button.with_label (_ ("Convert"));
            convert_start.valign = Gtk.Align.END;
            convert_start.vexpand = true;
            convert_start.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            convert_start.clicked.connect (convert_video);
            convert_container.attach (convert_start, 0, 3);

            convert_label = new Gtk.Label ("");
            convert_label.use_markup = true;
            set_convert_label ();
            convert_container.attach (convert_label, 0, 2);
            content.attach (convert_container, 2, 0);
        }

        private void set_convert_label () {
            if (selected_video == null) {
                this.convert_label.label = ("<i>%s</i>").printf (_ ("No Video file choosen…"));
            } else {
                this.convert_label.label = _ ("Ready!");
            }
        }

        private void on_converter_started () {
            open_video.sensitive = false;
            video_name.sensitive = false;
            video_logo.sensitive = false;
            select_format.sensitive = false;
            format_name.sensitive = false;
            format_logo.sensitive = false;
            convert_start.sensitive = false;
            convert_logo.sensitive = false;
            convert_label.opacity = 0;
            convert.active = true;
            app_notification.set_reveal_child (false);
        }

        private void on_converter_finished (bool success) {
            converter.finished.disconnect (on_converter_finished);

            open_video.sensitive = true;
            video_name.sensitive = true;
            video_logo.sensitive = true;
            select_format.sensitive = true;
            format_logo.sensitive = true;
            format_name.sensitive = true;
            convert_logo.sensitive = true;
            convert_start.sensitive = true;
            convert.active = false;
            convert_label.opacity = 1;
            string message;
            if (success) {
                message = _("%s was convert into %s").printf (selected_video.get_basename (), selected_formataudio.formataudio.get_name ());
            } else {
                message = _("Error while = convert %s into %s").printf (selected_video.get_basename (), selected_formataudio.formataudio.get_name ());
            }

            if (is_active) {
                app_notification.title = message;
                app_notification.send_notification ();
            } else {
                if (success) {
                    desktop_notification.set_title (_("Finished"));
                } else {
                    desktop_notification.set_title (_("Error"));
                }
                desktop_notification.set_body (message);
                application.send_notification ("notify.app", desktop_notification);
            }
        }

        private void convert_video () {
            if (!converter.is_running) {
                converter.finished.connect (on_converter_finished);
                converter.converter_now.begin (selected_video, selected_formataudio.formataudio); 
            }
        }

        private void update_formataudio_label () {
            switch (selected_formataudio.formataudio) {
                case Mindi.Formataudios.MP3:
                    break;
                case Mindi.Formataudios.M4A:
                    break;
                case Mindi.Formataudios.OGG:
                    break;
                case Mindi.Formataudios.WMA:
                    break;
                case Mindi.Formataudios.WAV:
                    break;
                default:
                    assert_not_reached ();
            }
        }

    }
}
