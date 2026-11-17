# Migrated / superseded local workflows

`pages-gh.yml` and `pages-sfu.yml` were local monoliths. Deploy implementation now lives in [`VWJF/rcg-sites`](https://github.com/VWJF/rcg-sites) leaf workflows, called one hop from `site.dispatch.yml`.

Former entrypoint `build.yml` was renamed to `site.dispatch.yml` and no longer `uses:` coastal-science.github.io.
