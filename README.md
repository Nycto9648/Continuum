# Modrinth Resource Pack Publishing Template

This template publishes one resource-pack ZIP to both GitHub Releases and Modrinth whenever a GitHub release is published.

## Resource-pack layout

Copy the unpacked resource pack into the repository. The workflow finds `pack.mcmeta` automatically, whether it is at the repository root or inside one containing folder.

Recommended layout:

```text
repository/
├── .github/
│   └── workflows/
│       └── publish.yml
├── assets/
├── pack.mcmeta
├── pack.png
└── README.md
```

Do not commit a manually created release ZIP. The workflow creates it.

## Configure each new repository

Open **Settings → Secrets and variables → Actions**.

Create this repository secret under **Secrets**:

| Secret | Value |
| --- | --- |
| `MODRINTH_TOKEN` | A Modrinth personal access token with permission to create versions |

Create these repository variables under **Variables**:

| Variable | Example |
| --- | --- |
| `MODRINTH_PROJECT_ID` | `jDHE5lOR` |
| `PACK_NAME` | `MobDoll` |
| `MIN_GAME_VERSION` | `1.21.4` |
| `MAX_GAME_VERSION` | `26.2` |

## Publish a version

1. Commit and push the resource-pack changes.
2. Create a GitHub release with a unique version tag such as `1.3.3`.
3. Add a release title and changelog.
4. Publish the release.

The workflow packages the folder containing `pack.mcmeta`, attaches the ZIP to the GitHub release, and publishes the same ZIP to Modrinth.

## Override compatibility for one release

To override the default Minecraft range, include a line like this in the release notes:

```text
Minecraft versions: >=1.21.4 <=26.3
```

If this line is absent, the workflow uses `MIN_GAME_VERSION` through `MAX_GAME_VERSION`.

## Turn this into a GitHub template

1. Push these files to a dedicated GitHub repository.
2. Open **Settings → General** for that repository.
3. Enable **Template repository**.
4. For each new pack, select **Use this template → Create a new repository**.
5. Copy in the new pack's unpacked files.
6. Configure that repository's secret and variables.

Never commit the Modrinth token into a file.
