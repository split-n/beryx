/*exported BeryxUtil */
var BeryxUtil = {
  secToTime(sec) {
    var m = Math.floor(sec / 60);
    var s = Math.floor(sec % 60);
    var mDig = 2;
    var sDig = 2;
    if (m >= 100) {
      mDig = 3;
    }
    return `${this.zeroPad(m, mDig)}:${this.zeroPad(s, sDig)}`;
  },
  zeroPad(val, dig) {
    return ("0".repeat(dig) + val).slice(-dig);
  }
};