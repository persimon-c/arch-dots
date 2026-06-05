pragma Singleton
import QtQuick

// StringUtils — pure string helpers. No UI, no imports beyond QtQuick.
//
// Usage:
//   Text { text: StringUtils.truncate(title, 40) }
//   Text { text: StringUtils.formatBytes(1536000) }         // "1.5 MB"
//   Text { text: StringUtils.formatDuration(245) }          // "4:05"
//   Text { text: StringUtils.capitalize("hello world") }    // "Hello World"

QtObject {
    id: root

    // -------------------------------------------------------------------------
    // truncate(str, maxLength, ellipsis?)
    // Truncates `str` to `maxLength` characters, appending `ellipsis` if cut.
    // Default ellipsis is "…" (U+2026 HORIZONTAL ELLIPSIS).
    // -------------------------------------------------------------------------
    function truncate(str: string, maxLength: int, ellipsis: string): string {
        if (!str) return ""
        const e = (ellipsis !== undefined) ? ellipsis : "…"
        if (str.length <= maxLength) return str
        return str.slice(0, maxLength - e.length) + e
    }

    // -------------------------------------------------------------------------
    // truncateMiddle(str, maxLength, ellipsis?)
    // Truncates from the middle, keeping start and end visible.
    // Useful for file paths.
    // -------------------------------------------------------------------------
    function truncateMiddle(str: string, maxLength: int, ellipsis: string): string {
        if (!str) return ""
        const e = (ellipsis !== undefined) ? ellipsis : "…"
        if (str.length <= maxLength) return str
        const half = Math.floor((maxLength - e.length) / 2)
        return str.slice(0, half) + e + str.slice(str.length - half)
    }

    // -------------------------------------------------------------------------
    // capitalize(str)
    // Capitalizes the first letter of each word.
    // -------------------------------------------------------------------------
    function capitalize(str: string): string {
        if (!str) return ""
        return str.replace(/\b\w/g, ch => ch.toUpperCase())
    }

    // -------------------------------------------------------------------------
    // capitalizeFirst(str)
    // Capitalizes only the very first character of the string.
    // -------------------------------------------------------------------------
    function capitalizeFirst(str: string): string {
        if (!str) return ""
        return str.charAt(0).toUpperCase() + str.slice(1)
    }

    // -------------------------------------------------------------------------
    // formatBytes(bytes, decimals?)
    // Converts a byte count to a human-readable string.
    // formatBytes(0)          → "0 B"
    // formatBytes(1536)       → "1.5 KB"
    // formatBytes(1073741824) → "1.0 GB"
    // -------------------------------------------------------------------------
    function formatBytes(bytes: real, decimals: int): string {
        if (bytes === 0) return "0 B"
        const d = (decimals >= 0) ? decimals : 1
        const k = 1024
        const units = ["B", "KB", "MB", "GB", "TB", "PB"]
        const i = Math.min(Math.floor(Math.log(bytes) / Math.log(k)), units.length - 1)
        const value = bytes / Math.pow(k, i)
        return value.toFixed(i === 0 ? 0 : d) + " " + units[i]
    }

    // -------------------------------------------------------------------------
    // formatDuration(seconds)
    // Formats a duration in seconds to a time string.
    // formatDuration(65)    → "1:05"
    // formatDuration(3723)  → "1:02:03"
    // -------------------------------------------------------------------------
    function formatDuration(seconds: real): string {
        const s = Math.max(0, Math.floor(seconds))
        const h = Math.floor(s / 3600)
        const m = Math.floor((s % 3600) / 60)
        const sec = s % 60
        const mm = m.toString().padStart(h > 0 ? 2 : 1, "0")
        const ss = sec.toString().padStart(2, "0")
        return h > 0
            ? h + ":" + mm + ":" + ss
            : mm + ":" + ss
    }

    // -------------------------------------------------------------------------
    // formatDurationVerbose(seconds)
    // Formats a duration with labels.
    // formatDurationVerbose(90)    → "1m 30s"
    // formatDurationVerbose(3700)  → "1h 1m"
    // -------------------------------------------------------------------------
    function formatDurationVerbose(seconds: real): string {
        const s = Math.max(0, Math.floor(seconds))
        const h = Math.floor(s / 3600)
        const m = Math.floor((s % 3600) / 60)
        const sec = s % 60
        if (h > 0) return h + "h " + m + "m"
        if (m > 0) return m + "m " + sec + "s"
        return sec + "s"
    }

    // -------------------------------------------------------------------------
    // formatRelativeTime(epochMs)
    // Returns a human-readable relative time string from an epoch timestamp (ms).
    // formatRelativeTime(Date.now() - 30000)  → "30s ago"
    // formatRelativeTime(Date.now() - 90000)  → "1m ago"
    // -------------------------------------------------------------------------
    function formatRelativeTime(epochMs: real): string {
        const diff = Math.floor((Date.now() - epochMs) / 1000)
        if (diff < 60)   return diff + "s ago"
        if (diff < 3600) return Math.floor(diff / 60) + "m ago"
        if (diff < 86400) return Math.floor(diff / 3600) + "h ago"
        if (diff < 604800) return Math.floor(diff / 86400) + "d ago"
        return Math.floor(diff / 604800) + "w ago"
    }

    // -------------------------------------------------------------------------
    // stripHtml(str)
    // Removes HTML tags from a string (for notification bodies).
    // -------------------------------------------------------------------------
    function stripHtml(str: string): string {
        if (!str) return ""
        return str.replace(/<[^>]*>/g, "").replace(/&amp;/g, "&")
                  .replace(/&lt;/g, "<").replace(/&gt;/g, ">")
                  .replace(/&quot;/g, "\"").replace(/&#39;/g, "'")
                  .replace(/&nbsp;/g, " ")
    }

    // -------------------------------------------------------------------------
    // initials(name, maxChars?)
    // Returns up to `maxChars` initials from a display name.
    // initials("John Doe")     → "JD"
    // initials("Alice")        → "A"
    // -------------------------------------------------------------------------
    function initials(name: string, maxChars: int): string {
        if (!name) return ""
        const max = (maxChars > 0) ? maxChars : 2
        return name.split(/\s+/)
                   .filter(w => w.length > 0)
                   .slice(0, max)
                   .map(w => w[0].toUpperCase())
                   .join("")
    }

    // -------------------------------------------------------------------------
    // pad(n, width, char?)
    // Left-pads a number or string to the given width.
    // pad(5, 2) → "05"
    // -------------------------------------------------------------------------
    function pad(n, width: int, char: string): string {
        const c = (char !== undefined) ? char : "0"
        return String(n).padStart(width, c)
    }

    // -------------------------------------------------------------------------
    // clamp(str, min, max)
    // Returns str unchanged if within length range, else truncates or pads.
    // -------------------------------------------------------------------------
    function clampLength(str: string, minLen: int, maxLen: int, padChar: string): string {
        if (!str) str = ""
        const c = (padChar !== undefined) ? padChar : " "
        if (str.length > maxLen) return str.slice(0, maxLen)
        return str.padEnd(minLen, c)
    }

    // -------------------------------------------------------------------------
    // formatPercent(value, decimals?)
    // formatPercent(0.756)  → "75.6%"
    // formatPercent(1.0, 0) → "100%"
    // -------------------------------------------------------------------------
    function formatPercent(value: real, decimals: int): string {
        const d = (decimals >= 0) ? decimals : 1
        return (value * 100).toFixed(d) + "%"
    }

    // -------------------------------------------------------------------------
    // basename(path)
    // Returns the filename part of a path string.
    // basename("/home/user/wallpapers/city.jpg") → "city.jpg"
    // -------------------------------------------------------------------------
    function basename(path: string): string {
        if (!path) return ""
        return path.split("/").filter(p => p.length > 0).pop() || ""
    }

    // -------------------------------------------------------------------------
    // stripExtension(filename)
    // Removes the file extension.
    // stripExtension("city.jpg") → "city"
    // -------------------------------------------------------------------------
    function stripExtension(filename: string): string {
        if (!filename) return ""
        const dot = filename.lastIndexOf(".")
        return dot > 0 ? filename.slice(0, dot) : filename
    }
}
