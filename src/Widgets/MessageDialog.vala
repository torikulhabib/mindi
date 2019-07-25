public class Mindi.MessageDialog : Gtk.Dialog {
    public string primary_text { 
        get {
            return primary_label.label;
        }
        set {
            primary_label.label = value;
        }
    }

    public string secondary_text { 
        get {
            return secondary_label.label;
        }
        set {
            secondary_label.label = value; 
        }
    }

    public GLib.Icon image_icon { 
        owned get {
            return image.gicon;
        }
        set {
            image.set_from_gicon (value, Gtk.IconSize.DIALOG);
        }
    }

    public Gtk.Label primary_label { get; construct; }

    public Gtk.Label secondary_label { get; construct; }

    public Gtk.ButtonsType buttons { 
        construct {
            switch (value) {
                case Gtk.ButtonsType.NONE:
                    break;
                case Gtk.ButtonsType.CLOSE:
                    add_button (_("_Close"), Gtk.ResponseType.CLOSE);
                    break;
                case Gtk.ButtonsType.CANCEL:
                    add_button (_("_Cancel"), Gtk.ResponseType.CANCEL);
                    break;
                case Gtk.ButtonsType.OK:
                case Gtk.ButtonsType.YES_NO:
                case Gtk.ButtonsType.OK_CANCEL:
                    warning ("Unsupported GtkButtonsType value");
                    break;
                default:
                    warning ("Unknown GtkButtonsType value");
                    break;
            }
        }
    }

    public Gtk.Bin custom_bin { get; construct; }

    private Gtk.Image image;

    private class SingleWidgetBin : Gtk.Bin {}

    public MessageDialog (Gtk.Window? parent, string primary_text, string secondary_text, GLib.Icon image_icon, Gtk.ButtonsType buttons = Gtk.ButtonsType.CLOSE) {
        Object (
            primary_text: primary_text,
            secondary_text: secondary_text,
            image_icon: image_icon,
            buttons: buttons,
            transient_for: parent,
            destroy_with_parent: true,
            window_position: Gtk.WindowPosition.CENTER_ON_PARENT
        );
    }

    public MessageDialog.with_image_from_icon_name (Gtk.Window? parent, string primary_text, string secondary_text, string image_icon_name = "dialog-information", Gtk.ButtonsType buttons = Gtk.ButtonsType.CLOSE) {
        Object (
            primary_text: primary_text,
            secondary_text: secondary_text,
            image_icon: new ThemedIcon (image_icon_name),
            buttons: buttons,
            transient_for: parent,
            destroy_with_parent: true,
            window_position: Gtk.WindowPosition.CENTER_ON_PARENT
        );
    }

    construct {
        resizable = false;
        deletable = false;
        skip_taskbar_hint = true;

        image = new Gtk.Image ();
        image.valign = Gtk.Align.START;

        primary_label = new Gtk.Label (null);
        primary_label.get_style_context ().add_class (Granite.STYLE_CLASS_PRIMARY_LABEL);
        primary_label.max_width_chars = 33;
        primary_label.wrap = true;
        primary_label.xalign = 0;

        secondary_label = new Gtk.Label (null);
        secondary_label.max_width_chars = 50;
        secondary_label.wrap = true;
        secondary_label.xalign = 0;

        custom_bin = new SingleWidgetBin ();
        custom_bin.add.connect (() => secondary_label.margin_bottom = 18);
        custom_bin.remove.connect (() => secondary_label.margin_bottom = 0);

        var message_grid = new Gtk.Grid ();
        message_grid.column_spacing = 0;
        message_grid.row_spacing = 0;
        message_grid.margin_start = message_grid.margin_end = 6;
        message_grid.attach (image, 0, 0, 1, 2);
        message_grid.attach (primary_label, 1, 0, 1, 1);
        message_grid.attach (secondary_label, 1, 1, 1, 1);
        message_grid.attach (custom_bin, 1, 2, 1, 1);
        message_grid.show_all ();

        get_content_area ().add (message_grid);

        var action_area = get_content_area ();
        action_area.margin = 3;
        action_area.margin_top = 3;

        button_press_event.connect ((e) => {
            if (e.button == Gdk.BUTTON_PRIMARY) {
                begin_move_drag ((int) e.button, (int) e.x_root, (int) e.y_root, e.time);
                return true;
            }
            return false;
        });
    }
}
