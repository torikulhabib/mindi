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

    public enum FolderMode {
        PLACE = 0,
        CUSTOM = 1,
        ASK = 2
    }
    public class Settings : Granite.Services.Settings {
        private static Settings? settings;
        public FolderMode folder_mode  { get; set; }
        private Settings () {
            base ("com.github.torikulhabib.mindi");
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
