# RepoZipper Cloud (gh-rz)nn[![Download RepoZipper Cloud](https://img.shields.io/badge/Download-RepoZipper%20Cloud-brightgreen)](https://github.com/rickballard/gh-rz/releases/latest)

# RepoZipper Cloud (gh-rz)  [![Free & Open](https://img.shields.io/badge/Free%20%26%20Open-CoCivium%20aligned-blue)](https://github.com/rickballard/gh-rz/releases/latest)

> **RepoZipper Cloud** is free for everyone. If you find it useful, please honor the voluntary [CoCivium Ethics Request](./ETHICS.md).

A GitHub CLI extension that creates read-only, Git-native, verifiable backups of your GitHub account (mirrored *.git bundles) with a simple restore kit.nn### Quickstart (2 commands)

```pwsh
gh extension install rickballard/gh-rz
gh rz -User $(gh api user --jq .login) -OutDir "$HOME\Desktop\GitHubRepoBackups"rnrn
<!-- docs: touch after MegaWave v0.2.6 -->

<!-- docs: tiny nudge for PR -->
