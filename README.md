
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
`https://cos-sh.tiye.me/Respo/markup/pr/<number>/<run-id>/` for PR previews.
COS action v1.1.1 uploads `dist` and verifies through `public-base-url`;
no separate upload verification script is needed. Production server deployment
keeps its original source and destination; PRs do not deploy to the server.

### Workflow

https://github.com/calcit-lang/respo-calcit-workflow

### License

MIT
