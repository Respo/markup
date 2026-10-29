
Markup
----

Demo http://repo.respo-mvc.org/markup/ .

### Usages

本次升级保留 Content 输入、Run、Reel 调试工具和原有本地存档格式。
旧页面升级后请完整刷新一次，以加载配对的运行时和正式模块。
这仍是现有 Demo，不新增 Markdown 解析或编辑功能。

当前 CLI/procs 配对正式 **0.32.1**，依赖固定到已发布的 Respo `0.17.1`、
UI `0.9.0`、Reel `0.7.0-alpha.5`、JS-FFI `0.2.9`，传递 Router `0.9.0-alpha.4`。
类型标注经官方 formatter 迁移；Snapshot 与原 main 经同一 formatter 规范化后的结果相同，
运行代码、公开合同、三项原测试、存档校验和 HUD 不变，不新增强转或放宽门禁。
本轮 all-defs 210 项、完整 strict、原三项 Node 回归、immutable/toolchain、文档与构建通过；
实际首屏/刷新无 warn/error，本轮未复验编辑、存档浏览器恢复或 HMR。
Reel/Router 仍为已发布 alpha，请重新安装完整依赖并生成 JS，避免混用旧缓存。
Content/Run、快捷键及存档 key 保持不变，UI 升级可能有样式差异。

0.31 迁移显式绑定 Respo 的入口事件类型，并在发送状态事件前检查游标确为 List。
本地 Store 保留原对象；旧存档中的同名外部 Struct 先转为 Map，经字段校验后重建本地 Store。
名称仅用于选择解码路径，不代表名义身份或可信来源。保留原三项业务测试。
启动仍先恢复存档，再渲染和注册保存；解析或解码失败会停止启动并保留原值。
解码失败和 reload 的 HUD 提示保持原行为，坏存档恢复 UI 尚未实现。

Caps 0.1.1、Node.js 24、Yarn 4.18.0。项目版本仍为尚未发布的 0.0.5 候选。
Canonical source and dependencies are `calcit.cirru` and `deps.cirru`;
retired compact/package snapshots are not used. Edit source with the Calcit CLI.

```sh
caps --strict --ci
yarn install --immutable
caps verify --toolchain
calcit calcit.cirru js
yarn vite
```

CI retains strict dependency resolution, entry/type checks and the existing
typed Reel rendering tests, and checks all definitions with all-defs plus the full strict workflow.
重复的手写CLI版本断言和namespace清单已移除，保留Caps工具链配对门禁，
不添加校验脚本、concurrently、质量预算或兼容强转。
开放的 Reel/UI 状态保留真实 Dynamic 边界；操作载荷经过检查并构造成具名 Op，
存档验证后恢复为 Store，不再依赖类型强转。DOM 挂载使用 Respo 的公开接口。
恢复时仅接受缺失游标或真实 List 游标；旧 Struct 定义恢复到当前 Store，
已是当前 Store 的值保留原对象。既有测试文件包含由迁移前 0.27.0 格式化器生成的
固定合成存档，经过实际 `:hydrate-storage` / Reel / Content 渲染路径，未使用用户存档。
完整 strict workflow 同时检查渲染入口的 Enum 守卫与 reload 的实际 Unit 返回。

### Deployment

Frontend build uses `VITE_BASE_URL`, pointing to
`https://cos-sh.tiye.me/Respo/markup/` on main and
`https://cos-sh.tiye.me/Respo/markup/pr/<number>/<run-id>/<attempt>/` for PR previews.
COS action v1.2.0 uploads `dist` and verifies through `public-base-url`;
no separate upload verification script is needed. Production server deployment
keeps its original source and destination; PRs do not deploy to the server.

同一 PR 的上传使用独立队列，生产上传使用另一个队列；保留排队任务，
不取消正在执行的上传。每次运行及重试使用不同预览路径，生产路径不变。
Action 使用精确正式 tag v1.2.0，验证由 Action 内置能力完成。

部署路径、COS 内置 verify 和前端/服务端边界不变。PR 不合并或自动部署生产。

### Workflow

https://github.com/calcit-lang/respo-calcit-workflow

### License

MIT
