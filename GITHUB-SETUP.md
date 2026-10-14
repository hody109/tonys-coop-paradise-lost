# GitHub setup and updates

## First upload

Use this project folder, not its parent workspace. The included `.gitignore` allows project sources, assets, mod payload and documentation while excluding installed game files, credentials, saves, logs and generated executables.

1. Install Git for Windows and sign in to GitHub using your normal browser authentication or credential manager.
2. On GitHub, create a repository named `tonys-coop-paradise-lost`. Start private while redistribution permissions are unresolved. Do not initialize it with a README, license or gitignore: those files are already prepared locally.
3. Open PowerShell in this folder. Replace `YOUR-ACCOUNT` below with your GitHub account name. Configure your Git name/email first if Git requests them; a GitHub no-reply address can be used.

```powershell
git init -b main
git add .
git status --short
git diff --cached --stat
git commit -m "Prepare Tony's coop: Paradise Lost"
git remote add origin https://github.com/YOUR-ACCOUNT/tonys-coop-paradise-lost.git
git push -u origin main
```

Review the staged list before committing. It must not include Runtime, Private, SaveBackups, Validation logs or launcher-settings.xml. Do not use `git add -f` to bypass these exclusions. Authenticate through the credential manager/browser; never put tokens in repository URLs, scripts, or chat.

## Later versions

Keep this folder as the working checkout. Before starting work, fetch remote changes and inspect them. After a change, build and run the relevant checks, review the diff, and commit only intended files. Push ordinary updates without force-pushing.

The assistant can make commits and push future versions from this checkout once the repository URL, working authentication and your authorization are provided. Pushes happen during requested work, not continuously in the background. Agree separately on whether each update should also create a release.

## Playable releases

GitHub's automatic source ZIP is a source snapshot, not the built launcher. For a playable version, build the launcher and attach a clean distribution ZIP to a GitHub Release. Use a tag such as `v0.1.0-experimental`, describe what changed and what was tested, and mark experimental builds as pre-releases. Resolve redistribution permissions before making the repository or downloads public.

Do not attach the complete installed project folder: it contains local game data and private configuration. Use an explicitly curated package without Runtime, Private, SaveBackups, launcher preferences or raw diagnostic logs.

Official references: [upload an existing project](https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github), [manage releases](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository).
