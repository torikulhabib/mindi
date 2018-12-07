namespace Mindi {
    public class TimeUtil {
        public static int duration_in_seconds (string duration) {
            string[] str = duration.split (".");
            string[] time = str[0].split (":");
            var hours = int.parse (time[0]);
            var mins = int.parse (time[1]);
            var secs = int.parse (time[2]);
            return secs + (hours * 3600) + (mins * 60);
        }
    }
}
