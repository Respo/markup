
Markup
----

Demo http://repo.respo-mvc.org/markup/ .

### Usages

本次候选 **0.0.5** 配对正式 Calcit / `@calcit/procs` **0.38.0**。
消费者需重新安装完整依赖图、生成 JS 并完整刷新页面。Content 输入、Run、Reel 调试工具、
存档 key 和格式保持；Demo 不新增 Markdown 解析功能。UI/Reel 跨 minor 升级可能有样式差异。
0.0.5 尚未发布，正式 tag 出现前不要将本分支当作已发布依赖。

依赖使用已发布的 Respo **0.19.5**、UI **0.15.2**、Reel **0.11.0**、JS-FFI **0.2.13**，
传递 Router **0.12.2**；不再使用 Reel / Router 的旧 alpha 图。
编辑回调派发具体 `Op`，Reel 0.11.0 面板与快捷键通过独立回调传递 `Control`。输入值由公开 `event-value` 检查为 String。
原 Reel 的 `read-field` 已删除；此处直接读取数据，保留 Map/Struct 字段读取及缺失值语义。
两个间隔分别保持 8 / 8px，开发态子节点显式使用 Option。
根渲染和原 SSR 回归均按 Respo 的公开 managed memo frame 合同包住构造与渲染。

应用 Op 与 Store 仍为原名义类型。存档继续在构造 `Op :hydrate-storage` 前独立校验。
Store.states 是应用与 Reel 共用的真实异构状态树，继续保留 Map Dynamic Dynamic；不以含 Dynamic
的 union 或伪泛型隐藏该边界。固定 Site 已是具体 Struct，不为本次升级引入无实际需要的 union。

启动仍先恢复成功，再渲染并注册保存。已有本地 Store 保留身份；旧同名外部 Struct 转为 Map，
验证后重建本地 Store，名称不代表来源或授权。游标可缺失；存在时须是由 Tag、字符串或数字组成的列表。
解析异常会停止启动并保留原存档，但不会显示此处的 HUD 提示；
只有 `decode-store` 返回 :none 时才显示原 HUD 错误，然后停止启动。坏存档恢复 UI 尚未实现。

使用 Node 24、Yarn 4.18.0、Caps 0.1.1：

```sh
caps --strict --ci
yarn install --immutable
caps verify --toolchain
calcit calcit.cirru --check-only --all-defs
calcit calcit.cirru fix --workflow strict --verify
calcit calcit.cirru js
node --test scripts/typed-reel-render.test.mjs
yarn vite
```

只维护 calcit.cirru / deps.cirru，不提交 compact.cirru、package.cirru 或 js-out。
编辑 Snapshot 使用官方 CLI 的受保护事务；原完整 strict 与 dynamic-method 门禁保留。
原三项回归及其中固定的 0.27.0 合成存档保持，SSR 仅增加公开 memo frame 入口，不改断言。
本地已验收合成中文/emoji 输入、Run、Reel 历史展示与刷新恢复；未声称所有 HMR 或坏存档 UI 已验收。

### Deployment

Frontend build uses `VITE_BASE_URL`, pointing to
`https://cos-sh.tiye.me/Respo/markup/` on main and
`https://cos-sh.tiye.me/Respo/markup/pr/<number>/<run-id>/<attempt>/` for PR previews.
COS action v1.3.0 uploads `dist` and verifies through `public-base-url`;
no separate upload verification script is needed. Production server deployment
keeps its original source and destination; PRs do not deploy to the server.

同一 PR 的上传使用独立队列，生产上传使用另一个队列；保留排队任务，
不取消正在执行的上传。每次运行及重试使用不同预览路径，生产路径不变。
Action 使用精确正式 tag v1.3.0，验证由 Action 内置能力完成。

部署路径、COS 内置 verify 和前端/服务端边界不变。PR 不合并或自动部署生产。

### Workflow

https://github.com/calcit-lang/respo-calcit-workflow

### License

MIT
