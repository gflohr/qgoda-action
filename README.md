# Qgoda 🍓 GitHub Pages Action

This GitHub Action builds a static site using [Qgoda](https://www.qgoda.net/)
🍓 and deploys it to a dedicated branch.

- [Qgoda 🍓 GitHub Pages Action](#qgoda--github-pages-action)
  - [Inputs](#inputs)
  - [Usage Example](#usage-example)
  - [How It Works](#how-it-works)
  - [Notes](#notes)
  - [Qgoda Site Structure](#qgoda-site-structure)
    - [Configure `permalink`](#configure-permalink)
    - [Configure `paths.site`](#configure-pathssite)
    - [Point Development Webserver to `_site`](#point-development-webserver-to-_site)
    - [Open Development Webserver at `/my-repo/`](#open-development-webserver-at-my-repo)
    - [Set `publish_dir`](#set-publish_dir)
    - [Other Strategies](#other-strategies)
  - [Examples](#examples)
  - [FAQ](#faq)
    - [How Can I use Other Package Managers Than `npm`?](#how-can-i-use-other-package-managers-than-npm)
    - [How Can I use Bun as a Package Manager?](#how-can-i-use-bun-as-a-package-manager)
    - [Why Does the Deployment Fail with `no such file or directory`?](#why-does-the-deployment-fail-with-no-such-file-or-directory)
    - [How Can I Make the Action More Verbose?](#how-can-i-make-the-action-more-verbose)
    - [How Can I Use the Action with a Monorepo](#how-can-i-use-the-action-with-a-monorepo)
  - [License](#license)

## Inputs

| Input Name       | Description                                  | Default        |
|-----------------|-----------------------------------------------|----------------|
| `docker-registry` | The container registry to use.              | `docker.io`    |
| `qgoda-image`   | The Docker image to use for Qgoda.            | `gflohr/qgoda` |
| `qgoda-version` | The version of Qgoda to use.                  | `latest-node`  |
| `qgoda-srcdir`  | Relative path to the source files.            | `.`            |
| `qgoda-command` | The Qgoda command to run.                     | `build`        |
| `image-data`    | Working directory inside the container image. | `/data`        |
| `alpine-dependencies` | Additional dependencies to install with `apk add` | ''   |

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
          qgoda-srcdir: './packages/docs'
          qgoda-command: '--verbose build'

      - name: Deploy
        uses: peaceiris/actions-gh-pages@v4
        if: github.ref == 'refs/heads/main'
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./packages/docs/_site/YOUR_REPO
```

## How It Works
1. Pulls the specified Qgoda Docker image.
2. Runs the Qgoda command (`build` by default) inside a container.
3. Uses the specified working directory to process site files.

## Notes
- Ensure that the `gh-pages` branch is correctly set up for deployment.
- Adjust `qgoda-version` as needed to use a specific Qgoda release.

## Qgoda Site Structure

GitHub pages have URLs of the form
`https://GITHUB_USERNAME.github.io/GITHUB_REPOSITORY`.  That means that all
URLs must be prefixed with the name of your GitHub repository.  There are
many ways that you can achieve that but the easiest is to automatically
prefix all permalinks in `_qgoda.yaml`. In detail:

### Configure `permalink`

We assume that your repository name is `my-repo`. Add this to your `_qgoda.yaml`:

```yaml
permalink: /my-repo{significant-path}
```

Do not put a slash in front of `{significant-path}`. It already begins with a
slash.

### Configure `paths.site`

Configure it like this:

```yaml
paths:
  site: ./_site/my-repo
```

### Point Development Webserver to `_site`

The document root of your development web server should still be `_site`.

### Open Development Webserver at `/my-repo/`

With that setup, you will point your webserver to
http://localhost:3000/my-site/.  This matches exactly 

### Set `publish_dir`

Assuming that you publish your pages with the custom GitHub action
[`peaceiris/actions-gh-pages@v4`](https://github.com/peaceiris/actions-gh-pages),
you should set the `publish_dir` variable to path where the pages are
rendered, for example `./packages/docs/_site/my-repo` like in the
[usage example above](#usage_example).

### Other Strategies

You could also use symbolic links to solve the prefix problem but inserting
the directory level with your repo name is actually the simplest approach.

## Examples

A very simple and basic example is
[qgoda-action-test](https://github.com/gflohr/qgoda-action-test). The
documentation files are located in the top-level directory.  The GitHub
workflow is defined in `.github/workflows/qgoda.yaml`.

The repo [e-invoice-eu](https://github.com/gflohr/e-invoice-eu) uses this
action in a monorepo. The documentation source files are located in
`packages/docs`, the same path that we use throughout this document.

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
directory. One easy way to achieve that is to define a `post-build` action
in `_qgoda.yaml`:

```yaml
post-build:
  - name: Disable Jekyll
    run: touch _site/.nojekyll
```

### How Can I Make the Action More Verbose?

Specify `--verbose build` (in this order!) for `qgoda-command`.

### How Can I Use the Action with a Monorepo

You only need to changes. You have to set the workflow input `qgoda-srcdir`
to the relative path to the documentation files, for example `packages/docs`.

If you are using
[`peaceiris/actions-gh-pages@v4`](https://github.com/peaceiris/actions-gh-pages)
for deploying your documentation, you must set the action's input `publish_dir`
not to `_site` but to `./packages/docs/_site` (or wherever your generated
documentation ends up).

## License

This action is released under the WTFPL-2.

