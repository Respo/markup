
Markup
----

Demo http://repo.respo-mvc.org/markup/ .

### Usages

本次升级保留 Content 输入、Run、Reel 调试工具和原有本地存档格式。
旧页面升级后请完整刷新一次，以加载配对的运行时和正式模块。
这仍是现有 Demo，不新增 Markdown 解析或编辑功能。

Calcit/procs 使用已发布的 `0.30.1-alpha.5` 候选配对，不是 0.30.1 正式版。
Respo `0.16.122`、UI `0.7.41`、Reel `0.6.39`、JS-FFI `0.2.3`
改用精确正式 tag，不再依赖旧 alpha 模块。Caps 0.1.1、Node.js 24、Yarn 4.18.0。
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
typed Reel rendering test, and checks all application public definitions.
开放的 Reel/UI 状态保留真实 Dynamic 边界；操作载荷经过检查并构造成具名 Op，
存档验证后恢复为 Store，不再依赖类型强转。DOM 挂载使用 Respo 的公开接口。

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
