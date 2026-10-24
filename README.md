
Markup
----

Demo http://repo.respo-mvc.org/markup/ .

### Usages

本次升级保留 Content 输入、Run、Reel 调试工具和原有本地存档格式。
旧页面升级后请完整刷新一次，以加载配对的运行时和正式模块。
这仍是现有 Demo，不新增 Markdown 解析或编辑功能。

当前CLI/procs配对正式 **0.30.1**，依赖同步正式Respo `0.16.126`、UI `0.8.1`、
Reel `0.6.42`、JS-FFI `0.2.6`，传递Router `0.8.38`，Vite 固定 `8.3.3`。请重新安装完整图并生成JS，
不混装旧alpha缓存；Content/Run合同、快捷键及存档格式/key不变，UI 升级可能有样式差异。
本轮迁移两处旧 Option 调用及静态高度写法，按真实生产者补充事件/watcher 合同。
启动调整为先恢复存档，再渲染和注册保存；解析或解码失败会停止启动并保留原值，
解码失败仍显示原 HUD 提示，不自动清空、修复或回退。坏存档恢复 UI 尚未实现，可能停留在空白页。
已有 reload 成功/报错 HUD 保留，不替换为 raise；原三项业务测试保留，不新增预算或验证脚本。
移除旧 procs 安装预批准，正式图使用普通安装策略。
保留尚未发布的0.0.5候选，本轮不发布tag/npm、不合并或部署Demo。
Caps 0.1.1、Node.js 24、Yarn 4.18.0。下文类型/存档修复属于之前已合并的源码迁移，
不将其alpha.5测试或浏览器结果当作本次正式图的新验收。
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
Action 固定到正式 v1.2.0 的已审查提交，验证由 Action 内置能力完成。

部署路径、COS 内置 verify 和前端/服务端边界不变。PR 不合并或自动部署生产。

### Workflow

https://github.com/calcit-lang/respo-calcit-workflow

### License

MIT
