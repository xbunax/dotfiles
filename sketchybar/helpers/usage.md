# Codex 用量组件

- UI：`items/widgets/usage.lua`；数据与透明 PNG 渲染：`helpers/usage.py`。
- 数据源：[CodexBar Codex 文档](https://github.com/steipete/CodexBar/blob/main/docs/codex.md) 使用的 OAuth 用量接口。
- 依赖：Python 3.9+ 标准库、macOS 自带 Perl（用于进程总超时），不依赖 CodexBar 应用、浏览器或图形库。

## 展示与操作

菜单栏仅显示动态图标；点击弹窗查看套餐、各窗口的**剩余**百分比、重置时间和更新时间。
双横条上方表示短期窗口，下方表示每周窗口；不存在的窗口只有灰色轨道。
服务端返回非周窗口时，按原始窗口顺序展示。橙色 ≤20%，红色 ≤10%。

- 左键：展开/收起；移出弹窗：关闭。
- 右键或弹窗“刷新用量”：手动刷新（至少间隔 15 秒，遵守限流冷却）。
- 自动每 5 分钟查询，倒计时每 30 秒更新；唤醒后尝试刷新。
- 灰色图标、警示标记及弹窗中的过期提示表示数据过期，不能当作实时读数。
- 窗口到期后不会凭空恢复 100%，必须等待服务器的新读数。

## 登录与隐私

读取 SketchyBar 进程环境中的 `$CODEX_HOME/auth.json`，默认 `~/.codex/auth.json`。
若使用自定义 CODEX_HOME，需要在启动 SketchyBar 的环境中设置它，而不只是交互式 shell 中设置。
仅支持原生 OAuth 文件，不支持 API Key、Keychain-only 登录或浏览器 Cookie。
未登录/登录过期时，通过 Codex 自身执行 `codex login`，本组件不会自动登录、续期或覆盖凭据。

固定向 `https://chatgpt.com/backend-api/wham/usage` 请求；不跟随重定向，不采用自定义代理站点的 base URL。
遵循系统/进程 HTTP 代理环境。凭据只在 helper 内存和 HTTPS 请求头中使用，不出现在命令行、日志或用量缓存中。
账号标识只输出哈希以隔离内存中的旧数据；不展示邮箱。

成功读数只存在内存中；网络失败只保留同账号读数并标记过期，认证失效或账号变化会清空。
图片写入 `~/Library/Caches/sketchybar-usage`（目录 0700、文件 0600，最多 96 张），无持久化 token 或账号元数据。
图像失败时退回文字进度，不影响额度读取。重载后重新获取数据，不跨重启保留旧额度。

## 验证

在 SketchyBar 配置目录执行：

```sh
luac -p items/widgets/usage.lua
python3 -c 'import ast; from pathlib import Path; ast.parse(Path("helpers/usage.py").read_text())'
```

以上语法检查完全离线，不读取真实凭据、不请求真实接口。
修改后使用 `sketchybar --reload` 应用。真实查询会消耗一次服务端请求，请避免高频手动刷新。
