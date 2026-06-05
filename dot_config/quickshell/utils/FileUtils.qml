pragma Singleton
import QtQuick

// FileUtils — path manipulation helpers.
// FileView (Quickshell.Io) covers all actual file I/O — this util only handles
// path string operations and URL ↔ path conversions that come up repeatedly.
//
// Usage:
//   FileView { path: FileUtils.configPath("quickshell/theme/colors.json") }
//   Image    { source: FileUtils.toUrl("/home/user/wallpapers/city.jpg") }
//   Text     { text: FileUtils.basename(someFilePath) }

QtObject {
    id: root

    // -------------------------------------------------------------------------
    // Home directory — resolved once at startup via Qt.resolvedUrl.
    // All helpers that build absolute paths use this.
    // -------------------------------------------------------------------------
    readonly property string home: {
        // Qt.resolvedUrl("~") doesn't expand tilde, so we use an env var read.
        // StandardPaths resolves the home folder reliably.
        return StandardPaths.writableLocation(StandardPaths.HomeLocation)
    }

    // -------------------------------------------------------------------------
    // configHome — XDG_CONFIG_HOME, defaults to ~/.config
    // -------------------------------------------------------------------------
    readonly property string configHome: {
        const xdg = Qt.environment ? Qt.environment["XDG_CONFIG_HOME"] : ""
        return (xdg && xdg.length > 0) ? xdg : home + "/.config"
    }

    // -------------------------------------------------------------------------
    // cacheHome — XDG_CACHE_HOME, defaults to ~/.cache
    // -------------------------------------------------------------------------
    readonly property string cacheHome: {
        const xdg = Qt.environment ? Qt.environment["XDG_CACHE_HOME"] : ""
        return (xdg && xdg.length > 0) ? xdg : home + "/.cache"
    }

    // -------------------------------------------------------------------------
    // dataHome — XDG_DATA_HOME, defaults to ~/.local/share
    // -------------------------------------------------------------------------
    readonly property string dataHome: {
        const xdg = Qt.environment ? Qt.environment["XDG_DATA_HOME"] : ""
        return (xdg && xdg.length > 0) ? xdg : home + "/.local/share"
    }

    // -------------------------------------------------------------------------
    // configPath(relative)
    // Builds an absolute path under XDG_CONFIG_HOME.
    // configPath("quickshell/theme/colors.json")
    //   → "/home/user/.config/quickshell/theme/colors.json"
    // -------------------------------------------------------------------------
    function configPath(relative: string): string {
        return configHome + "/" + relative
    }

    // -------------------------------------------------------------------------
    // cachePath(relative)
    // -------------------------------------------------------------------------
    function cachePath(relative: string): string {
        return cacheHome + "/" + relative
    }

    // -------------------------------------------------------------------------
    // dataPath(relative)
    // -------------------------------------------------------------------------
    function dataPath(relative: string): string {
        return dataHome + "/" + relative
    }

    // -------------------------------------------------------------------------
    // homePath(relative)
    // homePath("wallpapers/city.jpg") → "/home/user/wallpapers/city.jpg"
    // -------------------------------------------------------------------------
    function homePath(relative: string): string {
        return home + "/" + relative
    }

    // -------------------------------------------------------------------------
    // toUrl(path)
    // Converts an absolute filesystem path to a file:// URL string, which is
    // what Qt image providers and FileView expect.
    // toUrl("/home/user/wallpapers/city.jpg")
    //   → "file:///home/user/wallpapers/city.jpg"
    // -------------------------------------------------------------------------
    function toUrl(path: string): string {
        if (!path) return ""
        if (path.startsWith("file://")) return path
        if (path.startsWith("/")) return "file://" + path
        // Relative path — resolve relative to the QS config dir
        return Qt.resolvedUrl(path).toString()
    }

    // -------------------------------------------------------------------------
    // fromUrl(url)
    // Strips the file:// prefix to get a plain filesystem path.
    // fromUrl("file:///home/user/pic.jpg") → "/home/user/pic.jpg"
    // -------------------------------------------------------------------------
    function fromUrl(url: string): string {
        if (!url) return ""
        if (url.startsWith("file://")) return url.slice(7)
        return url
    }

    // -------------------------------------------------------------------------
    // basename(path)
    // Returns the filename component of a path.
    // basename("/home/user/wallpapers/city.jpg") → "city.jpg"
    // -------------------------------------------------------------------------
    function basename(path: string): string {
        if (!path) return ""
        const p = fromUrl(path)
        return p.split("/").filter(s => s.length > 0).pop() || ""
    }

    // -------------------------------------------------------------------------
    // dirname(path)
    // Returns the directory component of a path.
    // dirname("/home/user/wallpapers/city.jpg") → "/home/user/wallpapers"
    // -------------------------------------------------------------------------
    function dirname(path: string): string {
        if (!path) return ""
        const p = fromUrl(path)
        const parts = p.split("/")
        parts.pop()
        return parts.join("/") || "/"
    }

    // -------------------------------------------------------------------------
    // extension(path)
    // Returns the file extension, lowercase, without the dot.
    // extension("city.JPG") → "jpg"
    // -------------------------------------------------------------------------
    function extension(path: string): string {
        const name = basename(path)
        const dot = name.lastIndexOf(".")
        return dot >= 0 ? name.slice(dot + 1).toLowerCase() : ""
    }

    // -------------------------------------------------------------------------
    // stripExtension(path)
    // Returns the path without its file extension.
    // stripExtension("/home/user/wallpapers/city.jpg")
    //   → "/home/user/wallpapers/city"
    // -------------------------------------------------------------------------
    function stripExtension(path: string): string {
        if (!path) return ""
        const dot = path.lastIndexOf(".")
        const slash = path.lastIndexOf("/")
        return (dot > slash) ? path.slice(0, dot) : path
    }

    // -------------------------------------------------------------------------
    // isImage(path)
    // Returns true if the file extension looks like a supported image type.
    // -------------------------------------------------------------------------
    function isImage(path: string): bool {
        const ext = extension(path)
        return ["jpg", "jpeg", "png", "webp", "gif", "bmp", "svg", "tiff"].indexOf(ext) >= 0
    }

    // -------------------------------------------------------------------------
    // join(...parts)
    // Joins path segments, collapsing redundant slashes.
    // join("/home/user", "wallpapers", "city.jpg")
    //   → "/home/user/wallpapers/city.jpg"
    // -------------------------------------------------------------------------
    function join(...parts): string {
        return parts.filter(p => p && p.length > 0)
                    .join("/")
                    .replace(/\/+/g, "/")
    }
}
