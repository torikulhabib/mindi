/*
* Copyright (C) 2018  Torikul habib <torik.habib@gmail.com>
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
* Authored by: torikulhabib <torik.habib@gmail.com>
*/

namespace Mindi.Configs {
    public enum FormatAudios {
        AAC = 0,
        AC3 = 1,
        AIFF = 2,
        FLAC = 3,
        MMF = 4,
        MP3 = 5,
        M4A = 6,
        OGG = 7,
        WMA = 8,
        WAV = 9
    }
    public enum NotifyMode {
        NOTIFY = 0,
        SILENT = 1
    }
    public enum FolderMode {
        PLACE = 0,
        CUSTOM = 1,
        ASK = 2
    }
    public class Settings : Granite.Services.Settings {
        private static Settings? settings;
        public FormatAudios format_audios  { get; set; }
        public NotifyMode notify_mode  { get; set; }
        public FolderMode folder_mode  { get; set; }
        public string output_folder    { get; set; }
        public string ask_folder    { get; set; }
        public string folder_link    { get; set; }

        private Settings () {
            base ("com.github.torikulhabib.mindi");
        }

        public void update_formataudio (Mindi.Formataudios formataudio) {
            switch (formataudio) {
                case Mindi.Formataudios.AC3:
                    settings.format_audios = FormatAudios.AC3;
                    break;
                case Mindi.Formataudios.AIFF:
                    settings.format_audios = FormatAudios.AIFF;
                    break;
                case Mindi.Formataudios.FLAC:
                    settings.format_audios = FormatAudios.FLAC;
                    break;
                case Mindi.Formataudios.MMF:
                    settings.format_audios = FormatAudios.MMF;
                    break;
                case Mindi.Formataudios.MP3:
                    settings.format_audios = FormatAudios.MP3;
                    break;
                case Mindi.Formataudios.M4A:
                    settings.format_audios = FormatAudios.M4A;
                    break;
                case Mindi.Formataudios.OGG:
                    settings.format_audios = FormatAudios.OGG;
                    break;
                case Mindi.Formataudios.WMA:
                    settings.format_audios = FormatAudios.WMA;
                    break;
                case Mindi.Formataudios.WAV:
                    settings.format_audios = FormatAudios.WAV;
                    break;
                default:
                    settings.format_audios = FormatAudios.AAC;
                    break;
            }
        }

        public void notify_switch () {
            switch (settings.notify_mode) {
                case NotifyMode.NOTIFY:
                    settings.notify_mode = NotifyMode.SILENT;
                    break;
                default:
                    settings.notify_mode = NotifyMode.NOTIFY;
                    break;
            }
        }

        public void folder_switch () {
            switch (settings.folder_mode) {
                case FolderMode.PLACE:
                    settings.folder_mode = FolderMode.CUSTOM;
                    break;
                case FolderMode.CUSTOM:
                    settings.folder_mode = FolderMode.ASK;
                    break;
                default:
                    settings.folder_mode = FolderMode.PLACE;
                    break;
            }
        }

        public static unowned Settings get_settings () {
            if (settings == null) {
                settings = new Settings ();
            }
            return settings;
        }
    }
}
