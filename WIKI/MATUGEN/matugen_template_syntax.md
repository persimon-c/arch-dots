# Matugen: Comprehensive Technical Manual & Template Reference

Matugen is a cross-platform, Material You (MD3) and Base16 color generation engine built in Rust. It extracts color palettes from images or raw color seeds and dynamically interpolates them into text-based configuration files using a custom, high-performance templating engine built with Chumsky.

Templates can use any file extension but must be written in standard UTF-8 text encoding.

---

## 1. Command Line Interface (CLI) Usage

### Core Commands & Global Arguments

* **Help Flag:** View all available flags, subcommands, and structural options.
```bash
matugen -h

```



```
* **Generate from an Image:** Extracts palettes dynamically from an image file (e.g., a desktop wallpaper).
  ```bash
  matugen image /path/to/wallpaper.png

```

* **Generate from a Static Color:** Generates dynamic color themes directly using a static seed value.
```bash
# Generate using a Hex color value
matugen color hex "#ffbf9b"

# Generate using an HSL color value
matugen color hsl "hsl(20, 100%, 80%)"

```



```

### Advanced CLI Capabilities
* **Switching Modes:** If no mode is explicitly passed to the runtime generation instance, Matugen defaults to `dark`. Use the `-m` flag to toggle runtime contexts:
  ```bash
  matugen image /path/to/wallpaper.png -m light
  matugen color hex "#ffbf9b" -m dark

```

* **Raw JSON Outputting:** Instead of or alongside writing directly to your template files, you can output raw JSON directly to standard output (`stdout`).
```bash
matugen color hex "#ffbf9b" --json rgb

```



```
* **Custom Configuration Paths:** Point Matugen to a specialized settings file using the `-c` argument:
  ```bash
  matugen image /path/to/wallpaper.png -c /path/to/custom/matugen.toml

```

### Importing Custom JSON Data

Matugen allows external JSON fields to be merged into the template execution context. Data resolution follows a strict priority order (later calls overwrite previous fields):

1. Execution via the `--import-json` flag.
2. Execution via the `--import-json-string` flag.
3. Declarations found within the `[config.import_json_files]` block inside `config.toml`.

```bash
# Import external data from a dedicated file
matugen color hex "#ffbf9b" --import-json ./example/custom.json

# Import an inline JSON string raw from the terminal line
matugen color hex "#ffbf9b" --import-json-string '{ "custom_text": "Hello World" }'

```

---

## 2. Template Syntax Fundamentals

The structural layout inside files parsed by Matugen relies on explicit semantic boundaries.

| Block Type | Syntax Design | Functional Purpose |
| --- | --- | --- |
| **Expression** | `{{ expression }}` | Evaluates code math, handles filters, and prints values. |
| **Block Context** | `<* ... *>` | Wraps control statements like loops, conditionals, and includes. |
| **Escaping Sequence** | `\{{ ... }}` | Prevents interpretation; prints the literal string `{{ ... }}`. |

### Expressions and Navigation

Objects inside Matugen are rich data representations, not flat strings. Nested context elements are evaluated cleanly using dot notation structures:

```text
{{ colors.primary.default.hex }}
{{ palettes.error._99.hex }}
{{ mode }}

```

---

## 3. Color Formats & Context Mappings

### Exhaustive Color Formats

When interacting with any color variable, append any of the following parameters to format the raw value:

| Format Token | Output Structural Notation | Example Evaluation Output |
| --- | --- | --- |
| `hex` | `#RRGGBB` | `#470228` |
| `hex_stripped` | `RRGGBB` | `470228` |
| `hex_alpha` | `#RRGGBBAA` | `#470228ff` |
| `hex_alpha_stripped` | `RRGGBBAA` | `470228ff` |
| `alpha_hex` | `#AARRGGBB` | `#ff470228` |
| `alpha_hex_stripped` | `AARRGGBB` | `ff470228` |
| `rgb` | `rgb(r, g, b)` | `rgb(71, 2, 40)` |
| `rgba` | `rgba(r, g, b, a)` | `rgba(71, 2, 40, 1.0)` |
| `hsl` | `hsl(h, s, l)` | `hsl(332.2, 94.5%, 14.3%)` |
| `hsla` | `hsla(h, s, l, a)` | `hsla(332.2, 94.5%, 14.3%, 1.0)` |
| `red` | Integers (`0` - `255`) | `71` |
| `green` | Integers (`0` - `255`) | `2` |
| `blue` | Integers (`0` - `255`) | `34` |
| `alpha` | Floating Values (`0.0` - `1.0`) | `0.7` |
| `hue` | Angles (`0.0` - `360.0`) | `332.2` |
| `saturation` | Percentages (`0.0%` - `100.0%`) | `94.5%` |
| `lightness` | Percentages (`0.0%` - `100.0%`) | `14.3%` |

---

### Material Design 3 (MD3) Palette Mappings

Material Design 3 focuses on functional UI roles. Access these variables using the pattern: `{{ colors.<name>.<mode>.<format> }}` (e.g., `{{ colors.primary.default.hex }}`).

| Context Variable | Descriptive Mapping Context |
| --- | --- |
| `primary` | Main branding accent color across components. |
| `on_primary` | Text / graphical icons drawn directly over primary background elements. |
| `primary_container` | Soft containment values for structural blocks referencing primary accents. |
| `on_primary_container` | High contrast structural text layered over container frames. |
| `inverse_primary` | Primary color configuration mapping targeted for inverted dark/light UI scenarios. |
| `secondary` | Complementary branding configurations needing less contextual prominence. |
| `on_secondary` | Component overlay items layered directly atop secondary accents. |
| `secondary_container` | Subtle alternative structural frames. |
| `on_secondary_container` | Content text layered natively inside secondary groupings. |
| `tertiary` | Distinct balancing element meant to offset primary and secondary groupings. |
| `on_tertiary` | Direct context elements drawn directly on tertiary backgrounds. |
| `tertiary_container` | Background styling blocks set aside for tertiary elements. |
| `on_tertiary_container` | Elements overlaying tertiary container spaces. |
| `error` | System alert colors representing problems, warnings, or destructive actions. |
| `on_error` | Structural elements placed cleanly over alert states. |
| `surface` | Main backgrounds for structured elements like modal cards, drop menus, and sheets. |
| `on_surface` | Critical default text coloring drawn atop standard surface containers. |
| `surface_variant` | Alternative secondary background framing context. |
| `on_surface_variant` | Secondary textual markers placed inside alternative frame instances. |
| `outline` | Structural accents, dividers, system borders, and line wrappers. |
| `outline_variant` | Muted divider alternative context. |
| `background` | Primary global canvas backdrop framework for windows. |
| `on_background` | Baseline structural text mapped onto standard frame backdrops. |
| `shadow` | Color profiles used to cast elevation depth paths. |
| `scrim` | Color overlays used to darken backdrops behind interactive active models. |

---

### Base16 Framework Palette Mappings

Matugen incorporates Base16 structural mappings for shell syntax highlighting engines. Access these variables using the pattern: `{{ base16.<name>.<mode>.<format> }}` (e.g., `{{ base16.base00.default.hex }}`).

| Variable Name | Standardized Semantic Palette Definitions |
| --- | --- |
| `base00` | Default Master Window Background |
| `base01` | Lighter Frame Backgrounds (e.g., Status Bars, Panels) |
| `base02` | UI Selection Elements, Active Highlight Regions |
| `base03` | Code Comments, Subtle Marks, Invisible UI glyphs |
| `base04` | Dark Foreground Elements (Used predominantly inside specialized panels) |
| `base05` | Standard Default Foreground text, Editor Carets, Delimiters |
| `base06` | Light Foreground Text Variants |
| `base07` | Maximum Light Background Accent |
| `base08` | Primary Variables, Structural XML Tags, Standard Red Accent |
| `base09` | Numerical values, Boolean true/false markers, Constants, Orange Accent |
| `base0a` | Declared Classes, Strings, Function Names, Yellow Accent |
| `base0b` | String Content text, Inherited Code Framework classes, Green Accent |
| `base0c` | Core System Architecture support, Regular Expressions, Escape Tokens, Cyan Accent |
| `base0d` | Methods, Core Functional Blocks, Attribute ID hooks, Blue Accent |
| `base0e` | System Language Keywords, Storage definitions, Selector strings, Magenta Accent |
| `base0f` | Deprecated blocks, Code tag wrapping anchors, Brown Accent |

### Global Runtime States

* `{{ is_dark_mode }}`: Evaluates strictly to `true` or `false`.
* `{{ mode }}`: Evaluates to the literal configuration state string: `"dark"` or `"light"`.
* `{{ image }}`: The absolute path of the target wallpaper image parsed by the application.
* `{{ custom.<keyword> }}`: Fetches custom strings or blocks from your `config.toml`.

---

## 4. Control Flow Blocks & Logic Architecture

### Template Inclusion Statements

Templates can modularly reference external configuration assets via names declared within `config.toml`.

```text
<* include "includeme" *>

```

*Note: If an included component is meant only for internal block evaluations without generating its own target output file, simply omit or comment out its structural `output_path` property inside the master `config.toml` file block.*

### Conditional Logic Framework

Conditionals allow you to easily branch configurations. Version `v3.1.0` and above includes native support for explicit negation utilizing the `not` keyword.

```text
<* if {{ is_dark_mode }} *>
/* Theme output for Dark configurations */
background-color: {{ colors.background.default.hex }};
<* else *>
/* Theme output for Light configurations */
background-color: #ffffff;
<* endif *>

<* if not {{ is_dark_mode }} *>
/* Evaluates strictly when dark mode operations are absent */
border: 1px solid #000000;
<* endif *>

```

### Looping Iterators

Matugen provides two powerful looping structures: numerical ranges and object map traversals.

#### Numerical Range Loops (Inclusive Bounds)

```text
<* for i in -10..10 *>
.spacing-offset-{{ i }} {
    padding-top: {{ {{ i }} * 10 }}px;
}
<* endfor *>

```

#### Map and Dictionary Iterations

Iterates over key-value structures, such as checking all Material Design 3 structural values simultaneously:

```text
<* for name, value in colors *>
--md3-sys-color-{{ name }}: {{ value.default.hex }};
<* endfor *>

```

### Arithmetic and Expression Nesting

Expressions can compute equations natively or wrap mathematical parameters inside inline pipeline transforms:

```text
{{ {{ i }} * 10 }}
{{ colors.error.default.hex | lighten: {{ i }} * 10 }}

```

---

## 5. Built-In Filter System

Filters modify context metrics inline. Chain multiple rules using the standard pipe (`|`) character syntax.

### Color Transformations

The `to_color` filter parses a CSS string into a rich color object, allowing you to use color modification filters on hardcoded color strings directly within your template file.

* **`to_color`** Parses a CSS-style hex string layout into a structured color data block.
*Example:* `{{ "#ff00ff" | to_color }}`
* **`format`** Converts an arbitrary color value into a specific string representation.
*Arguments:* `String` (Target format layout archetype)
*Example:* `{{ "#ff00ff" | format: "hex" }}`
* **`set_red`** Overrides the 8-bit red value channel inside a designated object framework.
*Arguments:* `Int` (`0-255`)
*Example:* `{{ "#000000" | to_color | set_red: 255 }}`
* **`set_green`** Overrides the 8-bit green channel.
*Arguments:* `Int` (`0-255`)
*Example:* `{{ "#000000" | to_color | set_green: 255 }}`
* **`set_blue`** Overrides the 8-bit blue channel.
*Arguments:* `Int` (`0-255`)
*Example:* `{{ "#000000" | to_color | set_blue: 255 }}`
* **`set_alpha`** Adjusts opacity values within a color structure.
*Arguments:* `Float` (`0.0 - 1.0`)
*Example:* `{{ "#000000" | to_color | set_alpha: 0.1 }}`
* **`set_hue`** Alters standard HSL hue structural parameters.
*Arguments:* `Int` (`0-360`)
*Example:* `{{ "#000000" | to_color | set_hue: 360 }}`
* **`set_saturation`** Forces a set saturation parameter value.
*Arguments:* `Float` (`0.0 - 100.0`)
*Example:* `{{ "#000000" | to_color | set_saturation: 100.0 }}`
* **`set_lightness`** Forces a set color lightness metric parameter.
*Arguments:* `Int` (`0 - 100`)
*Example:* `{{ "#000000" | to_color | set_lightness: 100 }}`
* **`lighten`** Shifts a target color's lightness value higher.
*Arguments:* `Float` (Value adjustment parameter)
*Example:* `{{ "#ffffff" | to_color | lighten: 20.0 }}`
* **`invert`** Flips numerical bit values to generate an inverted contrast value.
*Example:* `{{ "#ffffff" | to_color | invert }}`
* **`grayscale`** Converts a color to a single greyscale channel value.
*Example:* `{{ "#ff0000" | to_color | grayscale }}`
* **`auto_lightness`** Dynamically checks values: light colors are darkened; dark colors are lightened.
*Arguments:* `Float` (Value adjustment scale)
*Example:* `{{ "#222222" | to_color | auto_lightness: 10.0 }}`
* **`saturate`** Alters saturation using specialized color models.
*Arguments:* `Float` (Amount), `String` (`"hsl"` or `"hsv"` space models)
*Example:* `{{ "#336699" | to_color | saturate: 20.0, "hsl" }}`
* **`blend`** Blends two distinct colors together using hue blending.
*Arguments:* `Color` (Target palette color object), `Float` (Ratio scale `0.0 - 1.0`)
*Example:* `{{ "#ff0000" | to_color | blend: {{ "#0000ff" | to_color }}, 0.5 }}`
* **`harmonize`** Shifts a source color's hue dynamically toward a second target color for better visual balance.
*Arguments:* `Color` (Target parameter context block)
*Example:* `{{ "#ff0000" | to_color | harmonize: {{ "#00ff00" | to_color }} }}`

---

### String Transformations

Use these filters to format text fields or transform custom imported properties.

* **`snake_case`**: Formats strings into `snake_case`.
*Example:* `{{ "Hello World" | snake_case }}` $\rightarrow$ `hello_world`
* **`lower_case`**: Formats strings into all lowercase characters.
*Example:* `{{ "Hello World" | lower_case }}` $\rightarrow$ `hello world`
* **`camel_case`**: Formats strings into standard camelCase.
*Example:* `{{ "hello world" | camel_case }}` $\rightarrow$ `helloWorld`
* **`pascal_case`**: Formats strings into PascalCase.
*Example:* `{{ "hello world" | pascal_case }}` $\rightarrow$ `HelloWorld`
* **`kebab_case`**: Formats strings into kebab-case.
*Example:* `{{ "hello world" | kebab_case }}` $\rightarrow$ `hello-world`
* **`replace`**: Swaps matching characters or words within a target string field.
*Arguments:* `String` (Match pattern target), `String` (Replacement text)
*Example:* `{{ "hello world" | replace: "world", "there" }}` $\rightarrow$ `hello there`

---

## 6. The Configuration Architecture (`config.toml`)

### Standard File Locations

Matugen automatically maps settings from the following platform-specific folders:

* **Linux/Unix:** `/home/user/.config/matugen/config.toml`
* **Windows:** `C:\Users\user\AppData\Roaming\InioX\matugen\config\config.toml`
* **MacOS:** `/Users/user/Library/Application Support/com.InioX.matugen/config.toml`

### Main Configuration & Wallpaper Manager

The configuration file structure uses dedicated tables to control core operations, handle asset dependencies, and execute external scripts.

```toml
[config]
reload_apps = true

# Modern Wallpaper Handler Block (v1.0.0+)
[config.wallpaper]
set = true
command = "swww"
arguments = ["img", "--transition-type", "center"]
# Alternatively, you can use raw single line shell expressions:
# command = "swww img --transition-type center {{ image }}"

[config.import_json_files]
custom_data = "~/.config/matugen/extras.json"

[config.custom_keywords]
font_main = "JetBrainsMono Nerd Font"

# Inlined structural configuration block layout
[templates.kitty]
input_path = '~/.config/matugen/templates/kitty.conf'
output_path = '~/.config/kitty/themes/matugen.conf'
post_hook = "kitty +kitten themes --reload-in=all matugen"

```

---

## 7. Advanced Template Configurations & Niche Features

### Custom Vector Alignment (`colors_to_compare`)

Matugen can compare a dynamically generated color against an array of static choices to find the closest match. This is highly useful for matching desktop accent modifications directly to pre-rendered system folders or static graphic items.

```toml
[templates.folder_icons]
input_path = "~/.config/matugen/templates/folder-color.toml"
output_path = "~/.config/papirus-folders.toml"
compare_to = "primary" # The MD3 color role used as the baseline anchor
colors_to_compare = [
    { name = "papirus-blue", color = "#4a86e8" },
    { name = "papirus-red", color = "#ff0000" },
    { name = "papirus-teal", color = "#00ffff" },
    { name = "papirus-yellow", color = "#ffff00" }
]

```

Inside your template file, access the string name matching the mathematically closest choice using:

```text
active_icon_pack = "{{ closest_color }}"

```

### Variable Substitutions in Hooks

Both `pre_hook` and `post_hook` shell strings support variable injection using standard interpolation syntax to pass operational context metrics into external reloader tools.

```toml
[templates.alacritty]
input_path = "~/.config/matugen/templates/alacritty.toml"
output_path = "~/.config/alacritty/alacritty.toml"
post_hook = 'notify-send "Matugen" "Successfully compiled system theme in {{ mode }} mode!"'

```

### Template-Level Layout Overrides

To keep a specific configuration file locked to a single presentation profile (for example, keeping text editors locked to Dark mode regardless of daytime wallpaper variations), declare explicit template-level parameter overwrites using `scheme_type`:

```toml
[templates.neovim]
input_path = "~/.config/matugen/templates/neovim.lua"
output_path = "~/.config/nvim/lua/theme.lua"
scheme_type = "dark" 

```

---

## 8. Practical End-to-End Walkthrough: Waybar Setup

This guide demonstrates how to dynamically generate a CSS color palette block, import it into an active Waybar environment, and trigger live refreshes automatically via signal hooks whenever a wallpaper changes.

### Step 1: Create the Source Color Template

Create a source color stylesheet skeleton layout at `~/.config/matugen/templates/colors.css`. This loop dynamically parses all generated Material Design 3 variables out as functional native CSS variables:

```css
/*
 * Waybar Stylesheet Palette
 * Generated dynamically via Matugen
 */
<* for name, value in colors *>
@define-color {{name}} {{value.default.hex}};
<* endfor *>

```

### Step 2: Import the Compiled Palette into Waybar

Reference the compiled output stylesheet inside your primary Waybar stylesheet (`~/.config/waybar/style.css`):

```css
@import "colors.css";

/* Apply the generated color roles directly to components */
window#waybar {
    background-color: @background;
    border-bottom: 2px solid @outline;
}

#workspaces button.focused {
    background-color: @primary_container;
    color: @on_primary_container;
}

```

### Step 3: Register everything inside `config.toml`

Open `~/.config/matugen/config.toml` and declare your paths alongside a `post_hook` to send an immediate reload signal (`SIGUSR2`) to the Waybar process upon generation:

```toml
[config]
reload_apps = true

[config.wallpaper]
set = true
command = "swww"
arguments = ["img", "--transition-type", "center"]

[templates.waybar]
input_path = '~/.config/matugen/templates/colors.css'
output_path = '~/.config/waybar/colors.css'
post_hook = "pkill -SIGUSR2 waybar"

```

### Step 4: Run the Engine

Execute the dynamic compilation suite against your active wallpaper choice:

```bash
matugen image ~/Pictures/Wallpapers/aurora.jpg

```