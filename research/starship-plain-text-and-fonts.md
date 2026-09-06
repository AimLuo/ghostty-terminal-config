# Starship Plain Text 与字体依赖

调研日期：2026-09-06  
范围：官方文档 / GitHub 源码 + 本仓库当前配置。不引用二手博客。

## 结论摘要

在「去掉 Ghostty 配置、改用 Starship plain-text、终端不固定」的前提下，**安装脚本不应再安装任何字体**（包括 `font-maple-mono-nf`）。

Starship 的 Plain Text Symbols 预设把模块符号改成 ASCII 纯文本，官方明确写给「没有 Unicode」的环境；提示符本身不再依赖 Nerd Font 或符号字体。  
`eza --icons` 与 Yazi **默认图标**仍会输出 Nerd Font 码位；没有覆盖这些字形的终端字体时会显示为方块/问号。但 brew 只是把字体装进系统，**不会**把未固定的终端切到这套字体上——装 Maple Mono NF 解决不了「终端不固定」的图标问题。

若仍要图标：让用户在自己的终端里选任意 Nerd Font（或 Symbols Nerd Font），而不是由本仓库安装脚本指定字体。若要彻底去掉字体依赖：去掉 `eza --icons`，并为 Yazi 覆盖 ASCII/emoji 图标。

---

## 1. Plain Text Symbols 预设：权威来源、命令、TOML 路径

### 权威页面

官方文档页：<https://starship.rs/presets/plain-text>

对应仓库文档源（默认分支 `main`）：<https://github.com/starship/starship/blob/main/docs/presets/plain-text.md>

预设索引把该预设列在「Presets」集合里：<https://starship.rs/presets/>  
源文件：<https://github.com/starship/starship/blob/main/docs/presets/README.md>

### 官方安装 / 应用命令

文档给出的唯一应用命令是：

```sh
starship preset plain-text-symbols -o ~/.config/starship.toml
```

来源：<https://starship.rs/presets/plain-text>  
同一命令也写在仓库文档里：<https://github.com/starship/starship/blob/main/docs/presets/plain-text.md>

CLI 预设名是 `plain-text-symbols`，不是 URL 路径里的 `plain-text`。

页面另提供下载链接 `/presets/toml/plain-text-symbols.toml`（相对 starship.rs）。

### 完整 TOML 的官方仓库路径

文档用 VitePress 引用嵌入完整 TOML：

```
<<< @/public/presets/toml/plain-text-symbols.toml
```

来源：<https://github.com/starship/starship/blob/main/docs/presets/plain-text.md>

因此权威 TOML 文件是：

- 仓库路径：`docs/public/presets/toml/plain-text-symbols.toml`
- raw：<https://raw.githubusercontent.com/starship/starship/main/docs/public/presets/toml/plain-text-symbols.toml>
- blob：<https://github.com/starship/starship/blob/main/docs/public/presets/toml/plain-text-symbols.toml>
- 站点下载：<https://starship.rs/presets/toml/plain-text-symbols.toml>

完整内容以发版 tag 上的该文件为准，此处不整份转录。GitHub `main` 与 starship.rs 文档站点会超前于 Homebrew 发行版（例如 1.26.0 还不认识 `jj_bookmark`）。本仓库 `starship/starship.toml` **钉在 Starship 1.26.0**：由本机 `starship preset plain-text-symbols` 生成，对应 <https://github.com/starship/starship/blob/v1.26.0/docs/public/presets/toml/plain-text-symbols.toml>。安装脚本会提示正在安装的是 1.26 预设。

TOML 形态（抽样，证明是 ASCII 词/标点，不是 Nerd Font 字形）：

| 模块 | 预设符号 | 来源 |
|------|----------|------|
| `character.success_symbol` | `[>](bold green)` | 同上 TOML |
| `character.error_symbol` | `[x](bold red)` | 同上 |
| `git_branch.symbol` | `"git "` | 同上 |
| `git_status.ahead` / `behind` | `>` / `<` | 同上 |
| `directory.read_only` | `" ro"` | 同上 |
| `jobs.symbol` | `"*"` | 同上 |
| `os.symbols.Macos` | `"mac "` | 同上 |

---

## 2. 设计目的：还要不要 Nerd Font / Unicode 符号字体？

### 官方怎么说 Plain Text

官方原文：

> This preset changes the symbols for each module into plain text. Great if you don't have access to Unicode.

来源：<https://starship.rs/presets/plain-text>  
以及 <https://github.com/starship/starship/blob/main/docs/presets/plain-text.md>  
预设索引重复同一句话：<https://github.com/starship/starship/blob/main/docs/presets/README.md>

含义：

1. 目标是把**每个模块**的符号改成纯文本。
2. 适用场景是「没有 Unicode」——比「没有 Nerd Font」更严。
3. 官方没有为该预设列任何字体前提。

对照实际 TOML：符号是 `git `、`>`、`x`、`aws ` 这类 ASCII，没有 Powerline（``）、emoji、Nerd Font Private Use Area。

**结论：使用该预设后，Starship 提示符不需要 Nerd Font，也不需要 Unicode 符号字体。**

### 和另外两个官方预设对照（避免混用）

| 预设 | 官方描述 | 字体前提 | 来源 |
|------|----------|----------|------|
| **Nerd Font Symbols** | 各模块改用 Nerd Font 符号 | **需要**「A Nerd Font installed and enabled in your terminal」 | <https://starship.rs/presets/nerd-font/> ；源 <https://github.com/starship/starship/blob/main/docs/presets/nerd-font.md> |
| **No Nerd Fonts** | 符号限制在 emoji 与 powerline；「even without a Nerd Font installed, you should be able to view all module symbols」 | 不需要 Nerd Font，但仍用 emoji / Powerline | <https://starship.rs/presets/no-nerd-font/> |
| **Plain Text Symbols** | 纯文本；「don't have access to Unicode」 | 不需要 Nerd Font，也不依赖 Unicode 符号 | <https://starship.rs/presets/plain-text> |

No Nerd Fonts ≠ Plain Text。前者仍可能要 emoji 字体或 Powerline 字形；后者连 Unicode 都不假设。

### 默认 Starship（不用预设）仍然要字体

安装指南 Prerequisites：

> A Nerd Font installed and enabled in your terminal (for example, try the FiraCode Nerd Font).

来源：<https://starship.rs/guide/>

默认 `git_branch.symbol` 是 Powerline 字形 `' '`。  
来源：<https://starship.rs/config/#git-branch>

FAQ「Why don't I see a glyph symbol in my prompt?」把「You are using a Nerd Font」列为系统配置检查项之一，并建议用 emoji 字体测 `\xf0\x9f\x90\x8d`、用 Powerline 测 `\xee\x82\xa0`。  
来源：<https://starship.rs/faq/#why-don-t-i-see-a-glyph-symbol-in-my-prompt>

这些说的是**默认/带字形的配置**，不能套到 Plain Text 预设上。换预设之后，官方对「看不见字形」的字体建议不再适用于提示符本身。

---

## 3. 本仓库：eza、Yazi、旧 Ghostty 是否仍依赖 Nerd Font

### 3.1 旧 Ghostty：是，曾明确钉死 Maple Mono NF

重构前的 `ghostty/config`（现已删除）：

```
# font-family: 终端字体，需要 Nerd Font 版本才能显示图标
font-family = "Maple Mono NF"
```

来源：重构前本仓库 `ghostty/config`。

Maple Mono 上游自称带 Nerd Font 图标：

> Open source monospace font with round corner, ligatures and Nerd-Font icons for IDE and terminal

来源：<https://github.com/subframe7536/maple-font>

`install.sh` 与 README 都执行：

```sh
brew install --cask font-maple-mono-nf
```

来源：本仓库 `install.sh`、`README.md`。

去掉 Ghostty 配置后，本仓库不再有任何地方把终端 `font-family` 设成 Maple Mono NF。brew 装字体只影响系统字体库，不改变用户自选终端的当前字体。

### 3.2 eza `--icons`：是，默认图标是 Nerd Font 码位

重构前本仓库 `zsh/.zshrc`：

```sh
alias ls="eza --icons --group-directories-first"
alias ll="eza -l --icons --sort=name"
alias lt="eza --tree --icons --level=2"
```

重构后已去掉 `--icons`。下面仍说明旧别名为何会制造字体依赖。

官方 man 只定义开关，不写字体名：

> `--icons=WHEN`: Display icons next to file names.

来源：<https://github.com/eza-community/eza/blob/main/man/eza.1.md>

图标**内容**在源码里写死为 Nerd Font / PUA 码位，例如：

```rust
const AUDIO: char = '\u{f001}'; // 
const FOLDER: char = '\u{e5ff}'; // 
const FILE: char = '\u{f15b}';   // 
```

来源：<https://github.com/eza-community/eza/blob/main/src/output/icons.rs>

CHANGELOG 写明图标来自 Nerd Fonts：

> Add icons from nerd fonts 3.3.0 release & more

来源：<https://github.com/eza-community/eza/blob/main/CHANGELOG.md>

维护者在官方仓库 issue 中称应只支持 Nerd Fonts 3.0 以后。  
来源：<https://github.com/eza-community/eza/issues/1473>（cafkafk，2025-09-06）

eza 允许用 `theme.yml` 把 glyph 改成 emoji 等，但**本仓库没有 eza 主题**，走的是上述默认 Nerd Font 表。  
主题机制：<https://github.com/eza-community/eza/blob/main/man/eza_colors-explanation.5.md>  
示例：<https://github.com/eza-community/eza/blob/main/docs/theme.yml>

因此：只要别名里还留着 `--icons`，**显示是否正确取决于用户终端当前字体是否含这些字形**，与 Starship 是否 plain-text 无关。

### 3.3 Yazi 默认图标：是，官方推荐 Nerd Fonts

本仓库没有 `yazi.toml` / `theme.toml`。用户跑 `y` / `yazi` 时用 Yazi 内置预设。

官方安装页把 nerd-fonts 列为可选但推荐的前提：

> nerd-fonts (recommended)

来源：<https://yazi-rs.github.io/docs/installation>

官方 Homebrew 安装命令显式带上符号字体：

```sh
brew install yazi ... font-symbols-only-nerd-font
```

来源：同上页 Homebrew 一节。

主题文档：内置 nvim-web-devicons；示例图标是 Nerd Font 字形（如 `text = ""`）。  
来源：<https://yazi-rs.github.io/docs/configuration/theme#icon>

默认暗色主题 `[icon]` 同样是 Nerd Font 字形，例如 Desktop ``、`.git` ``。标签分隔符还用了 Powerline：`` / ``。  
来源：<https://github.com/sxyazi/yazi/blob/shipped/yazi-config/preset/theme-dark.toml>

Yazi 维护者说明：渲染由终端负责，系统包装常把 `ttf-nerd-fonts-symbols` 当依赖，用户仍需在终端里配好字体。  
来源：<https://github.com/sxyazi/yazi/discussions/1678>（sxyazi，2024-09-26）

**Yazi 能运行、能列文件，不依赖 Nerd Font；默认图标/部分 UI 分隔符要终端能画出这些字形。**

---

## 4. 必须分清的两件事

### Starship 不需要字体（在 plain-text 前提下）

Plain Text 预设把 prompt 里的模块符号换成 ASCII。官方适用条件是「没有 Unicode」。  
来源：<https://starship.rs/presets/plain-text>

因此：

- 不必为 Starship 装 Nerd Font、Maple Mono NF、Symbols Nerd Font。
- 默认指南 / FAQ 里的 Nerd Font 前提，针对的是默认或 Nerd Font 预设，不是这个预设。
- 换预设后，提示符在任意常见等宽字体下都应可读。

### `eza --icons`（以及 Yazi 默认图标）仍可能需要字体

`--icons` 不是「彩色」，而是往文件名旁边打印 `icons.rs` 里的 Nerd Font 字符。  
来源：<https://github.com/eza-community/eza/blob/main/src/output/icons.rs>  
man：<https://github.com/eza-community/eza/blob/main/man/eza.1.md>

Yazi 默认 `[icon]` 同理。  
来源：<https://github.com/sxyazi/yazi/blob/shipped/yazi-config/preset/theme-dark.toml>

终端字体若没有这些码位：图标变方块/问号，eza/Yazi 本身仍工作。  
装字体 ≠ 终端在用该字体。本仓库原先靠 Ghostty `font-family = "Maple Mono NF"` 把两件事绑在一起；去掉 Ghostty 配置后，这条链断了。

| 层 | 还依赖 Nerd Font？ | 谁能保证终端用到该字体？ |
|----|-------------------|--------------------------|
| Starship plain-text | 否 | 不需要 |
| eza `--icons`（重构前 alias） | 是（默认 glyph） | 仅当用户终端已选含这些字形的字体 |
| Yazi 默认图标 | 是（官方推荐） | 同上 |
| brew 安装 `font-maple-mono-nf` | 只提供文件 | **不能**，终端不固定 |

---

## 5. 安装脚本还该不该装字体？

前提：去掉 Ghostty 配置、Starship 用 plain-text、终端不由本仓库指定。

**不应再安装 `font-maple-mono-nf` 或任何字体。**

理由：

1. **Starship 侧没有字体需求。** Plain Text 官方就是为无 Unicode 环境准备的。  
   <https://starship.rs/presets/plain-text>
2. **本仓库失去唯一能「选用字体」的配置面。** 旧链路是 `install.sh` 装 Maple Mono NF + `ghostty/config` 设置 `font-family`。只留 brew、不写终端配置，字体不会自动生效。
3. **终端不固定时，指定 Maple Mono NF 没有稳定收益。** 各终端的字体设置互相独立；脚本无法、也不应去改 iTerm / Terminal.app / Warp / Kitty / 用户自管 Ghostty。
4. **eza / Yazi 的图标问题不能靠「偷偷装一套本仓库指定字体」解决。**  
   - 要兼容任意终端：去掉 `--icons`，覆盖 Yazi 图标为 ASCII/emoji。  
   - 要保留图标：文档写清「请在你的终端启用任意 Nerd Font（Yazi 官方 Homebrew 示例是 `font-symbols-only-nerd-font`）」。  
   Yazi 官方推荐的是 Symbols Nerd Font，不是 Maple Mono NF。  
   <https://yazi-rs.github.io/docs/installation>
5. 继续 `brew install --cask font-maple-mono-nf` 会多一次与提示符无关的 cask、多一个本仓库不再引用的字体名，却仍无法保证图标显示。

重构后现状：`starship/starship.toml` 是钉在 Starship 1.26.0 的 official plain-text；`install.sh` 不装字体、不写终端配置；`zsh/.zshrc` 的 eza 别名已去掉 `--icons`。Yazi 仍用它自己的默认图标，不在本仓库安装范围内。

---

## 一手来源

| 主题 | URL |
|------|-----|
| Plain Text 文档页 | https://starship.rs/presets/plain-text |
| Plain Text 文档源 | https://github.com/starship/starship/blob/main/docs/presets/plain-text.md |
| Plain Text 完整 TOML（1.26.0） | https://github.com/starship/starship/blob/v1.26.0/docs/public/presets/toml/plain-text-symbols.toml |
| 预设索引 | https://github.com/starship/starship/blob/main/docs/presets/README.md |
| Nerd Font 预设（对照） | https://starship.rs/presets/nerd-font/ |
| No Nerd Fonts 预设（对照） | https://starship.rs/presets/no-nerd-font/ |
| Starship 安装指南 Prerequisites | https://starship.rs/guide/ |
| Starship 默认 git_branch 符号 | https://starship.rs/config/#git-branch |
| Starship FAQ 字形 | https://starship.rs/faq/#why-don-t-i-see-a-glyph-symbol-in-my-prompt |
| eza `--icons` man | https://github.com/eza-community/eza/blob/main/man/eza.1.md |
| eza 默认图标源码 | https://github.com/eza-community/eza/blob/main/src/output/icons.rs |
| eza CHANGELOG（Nerd Fonts 3.3.0） | https://github.com/eza-community/eza/blob/main/CHANGELOG.md |
| eza 主题可改 glyph | https://github.com/eza-community/eza/blob/main/docs/theme.yml |
| Yazi 安装（nerd-fonts recommended） | https://yazi-rs.github.io/docs/installation |
| Yazi 图标配置 | https://yazi-rs.github.io/docs/configuration/theme#icon |
| Yazi 默认 theme-dark.toml | https://github.com/sxyazi/yazi/blob/shipped/yazi-config/preset/theme-dark.toml |
| Maple Mono（Nerd-Font icons） | https://github.com/subframe7536/maple-font |
| 本仓库（重构后） | `zsh/.zshrc`、`install.sh`、`starship/starship.toml` |
