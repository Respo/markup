
Markup
----

Demo http://repo.respo-mvc.org/markup/ .

### Usages

Use Calcit/procs 0.27.0, Caps 0.1.1, Node.js 24 and Yarn 4.18.0.
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

本轮仅更新 COS/CDN 配置，不改变 Calcit 0.27.0、既有模块版本、类型门禁
和业务测试。独立 Calcit 0.28.0 候选仍被共享 JS-FFI 的
`KeyboardEventHost` 类型断言阻塞；本轮成功不代表完整 0.28 升级完成。

### Workflow

https://github.com/calcit-lang/respo-calcit-workflow

### License

MIT
