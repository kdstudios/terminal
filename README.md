# Wasteland Terminal

A Flutter wasteland-survival RPG. This repository is set up to publish a browser-playable version using GitHub Pages.

## Publish the game (beginner-friendly)

1. Sign in to [GitHub](https://github.com/) or create a free account.
2. Create a **new repository**. Name it `wasteland-terminal`.
   - Choose **Public**.
   - Do not add a README, .gitignore, or licence (this folder already contains project files).
3. On the new repository page, choose **Add file → Upload files**.
4. Open the downloaded project folder on your computer. Select all the files and folders inside it, including the hidden `.github` folder, and drag them into GitHub's upload area.
   - Important: upload the contents of this folder, not an extra enclosing folder.
   - If the `.github` folder is hidden by your computer, enable showing hidden files so the deployment workflow is included.
5. Add a commit message such as `Add Wasteland Terminal` and choose **Commit changes**.
6. In the repository, open **Settings → Pages**. Under **Build and deployment**, set **Source** to **GitHub Actions**.
7. Open the **Actions** tab. Wait for **Build and publish Wasteland Terminal** to finish with a green checkmark.
8. Your game should then be available at:

   `https://YOUR-GITHUB-USERNAME.github.io/wasteland-terminal/`

   Replace `YOUR-GITHUB-USERNAME` with your GitHub username.

## Updating the game later

Upload changed project files to the same repository and commit them to the `main` branch. GitHub Actions will rebuild and republish the browser version automatically.

## Notes

- The workflow creates the Flutter web platform files during its build, then publishes the generated browser app to GitHub Pages.
- The original Android/iOS project files are retained.
- This is a browser-hosted version; it does not automatically create an app-store listing.
- Game saves currently use the app's local browser storage. They may not automatically sync between different devices or browsers.
