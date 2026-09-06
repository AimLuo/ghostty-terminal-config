# Starship plain-text 与字体

## 问题

去掉 Ghostty 配置后，改用 [Plain Text Symbols](https://starship.rs/presets/plain-text)，安装脚本还要不要装 Nerd Font（旧方案是 Maple Mono NF）？

## 发现

### Starship plain-text 预设

- 官方页面：<https://starship.rs/presets/plain-text>
- 官方说明：把各模块符号改成 plain text。适用场景是 **没有 Unicode**。
- 安装命令：`starship preset plain-text-symbols -o ~/.config/starship.toml`
- 权威 TOML：<https://raw.githubusercontent.com/starship/starship/master/docs/public/presets/toml/plain-text-symbols.toml>
- 符号全部是 ASCII / 基本拉丁字（`>`、`x`、`git `、`nodejs `），不依赖 Nerd Font 私用区字形。

### 和「No Nerd Fonts」预设不是同一件事

- [No Nerd Fonts](https://starship.rs/presets/no-nerd-font) 仍使用 emoji 和 powerline。
- Plain Text Symbols 更彻底：连 Unicode 装饰都不依赖。
- 本仓库按用户指定使用 plain-text，不是 no-nerd-font。

### eza `--icons` 仍可能要字体

- eza 手册：`--icons` 在文件名旁显示图标；`EZA_ICONS_AUTO` 会默认开图标。来源：<https://github.com/eza-community/eza/blob/main/man/eza.1.md>
- 旧 `zsh/.zshrc` 写了 `eza --icons`。这些图标通常来自 Nerd Font。
- 若保留 `--icons`，去掉 Maple Mono NF 后，部分终端仍会显示方框或错字。
- 决策：去掉 `--icons`，本仓库控制的 `ls`/`ll`/`lt` 不再制造字体依赖。

### 旧 Ghostty 字体配置

- 旧 `ghostty/config` 写了 `font-family = "Maple Mono NF"`，注释写明需要 Nerd Font 才能显示图标。
- 该文件随 Ghostty 配置一起移除。终端字体改由用户自己的模拟器决定。

### Yazi

- 本仓库不提供 Yazi 主题/图标配置。Yazi 自己的默认图标若需要字体，不在本安装脚本职责内。

## 结论

安装脚本 **不应再安装任何字体**。

| 组件 | 还要不要 Nerd Font |
|------|-------------------|
| Starship plain-text-symbols | 不要 |
| eza 别名（无 `--icons`） | 不要 |
| Ghostty / Maple Mono NF | 不再安装、不再配置 |
| 用户自选终端的字体 | 用户自己管 |
