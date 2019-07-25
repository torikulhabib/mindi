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

namespace Mindi {
    public class Remover : Object {
        static Remover _instance = null;
        public static Remover instance {
            get {
                if (_instance == null)
                    _instance = new Remover ();
                return _instance;
            }
        }
        private ObjectConverter? converter;
        public Remover () {}
        public async void remove_file (Mindi.Formataudios formataudio) {
            converter = ObjectConverter.instance;
            string failed_removed;
            switch (formataudio) {
                case Mindi.Formataudios.AC3:
                    failed_removed = converter.ac3_path;
                    break;
                case Mindi.Formataudios.AIFF:
                    failed_removed = converter.aiff_path;
                    break;
                case Mindi.Formataudios.FLAC:
                    failed_removed = converter.flac_path;
                    break;
                case Mindi.Formataudios.MMF:
                    failed_removed = converter.mmf_path;
                    break;
                case Mindi.Formataudios.MP3:
                    failed_removed = converter.mp3_path;
                    break;
                case Mindi.Formataudios.M4A:
                    failed_removed = converter.m4a_path;
                    break;
                case Mindi.Formataudios.OGG:
                    failed_removed = converter.ogg_path;
                    break;
                case Mindi.Formataudios.WMA:
                    failed_removed = converter.wma_path;
                    break;
                case Mindi.Formataudios.WAV:
                    failed_removed = converter.wav_path;
                    break;
                default:
                    failed_removed = converter.aac_path;
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
