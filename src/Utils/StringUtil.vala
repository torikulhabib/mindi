namespace Mindi {
    public class StringUtil {
        public const string SPACE = " ";
        public const string EMPTY = "";
        public const string BREAK_LINE = "\n";
        public static bool is_empty (string? value) {
            return value == null || value.length == 0;
        }
        public static bool is_not_empty (string? value) {
            return !is_empty (value);
        }
        public static bool is_blank (string? value) {
            if (value == null || value.length == 0) {
                return true;
            }

            for (int i = 0; i < value.length; i++) {
                if (value[i] != ' ') {
                    return false;
                }
            }

            return true;
        }
        public static bool is_not_blank (string? value) {
            return !is_blank (value);
        }
    }
}
