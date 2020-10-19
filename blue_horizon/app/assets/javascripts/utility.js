/*
 * functions used by other functions
 */

// https://stackoverflow.com/questions/10420352/converting-file-size-in-bytes-to-human-readable-string
// https://creativecommons.org/licenses/by-sa/4.0/
function humanFileSize(bytes, si) {
  var thresh = si ? 1000 : 1024;
  if (Math.abs(bytes) < thresh) {
    return bytes + " B";
  }
  var units = si
    ? ["kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
    : ["KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"];
  var u = -1;
  do {
    bytes /= thresh;
    ++u;
  } while (Math.abs(bytes) >= thresh && u < units.length - 1);
  if (Number.isInteger(bytes)) {
    return bytes.toString() + " " + units[u];
  } else {
    return bytes.toFixed(1) + " " + units[u];
  }
}
