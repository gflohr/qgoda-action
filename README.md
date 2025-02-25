# Qgoda GitHub Pages Action

This GitHub Action builds a static site using [Qgoda](https://www.qgoda.net/)
and deploys it to a dedicated branch.

## Inputs

| Input Name       | Description                                  | Default        |
|-----------------|-----------------------------------------------|----------------|
| `docker-registry` | The container registry to use.              | `docker.io`    |
| `qgoda-image`   | The Docker image to use for Qgoda.            | `gflohr/qgoda` |
| `qgoda-version` | The version of Qgoda to use.                  | `latest-node`  |
| `qgoda-srcdir`  | Relative path to the source files.            | `.`            |
| `qgoda-command` | The Qgoda command to run.                     | `build`        |
| `image-data`    | Working directory inside the container image. | `/data`        |

## Usage Example

```yaml
name: Deploy Qgoda Site

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Build and Deploy with Qgoda
        uses: gflohr/qgoda-action@v1
        with:
          qgoda-srcdir: '.'
          qgoda-command: '--verbose build'

      - name: Deploy
        uses: peaceiris/actions-gh-pages@v4
        if: github.ref == 'refs/heads/main'
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./_site
```

## How It Works
1. Pulls the specified Qgoda Docker image.
2. Runs the Qgoda command (`build` by default) inside a container.
3. Uses the specified working directory to process site files.

## Notes
- Ensure that the `gh-pages` branch is correctly set up for deployment.
- Adjust `qgoda-version` as needed to use a specific Qgoda release.

## FAQ

### How Can I use Other Package Managers Than `npm`?

If you are using `pnpm` or `yarn` in your `package.json` scripts, you first
have to install them as a `pre-build` task. The following excerpt from a
`_qgoda.yaml` is a complete example for using `pnpm`:

```yaml
pre-build:
  - name: Install pnpm
    run: npm install --include=dev pnpm
  - name: Build assets
    run: pnpm run build
```

Alternatively, you could have installed `pnpm` inside a `prebuild` script in
your `package.json`.

### How Can I use Bun as a Package Manager?

This is, unfortunately, not possible at this time, see the [bun
issue #5545](https://github.com/oven-sh/bun/issues/5545).

### Why Does the Deployment Fail with `no such file or directory`?

Do you see this error?

```
cp: no such file or directory: /home/runner/work/qgoda-action-test/qgoda-action-test/_site/.*
```

tl;dr: Ignore it!

For more details: See the issue https://github.com/peaceiris/actions-gh-pages/issues/892

If you want to get rid of the error, you have to make sure that a hidden file
(a file that has a name starting with a dot `.`) exists inside the `_site`
directory. The [example workflow from
`qgoda-action-test`](https://github.com/gflohr/qgoda-action-test/blob/main/.github/workflows/qgoda.yaml)
shows this.

### How Can I Make the Action More Verbose?

Specify `--verbose build` (in this order!) for `qgoda-command`.

## License

This action is released under the WTFPL-2.

