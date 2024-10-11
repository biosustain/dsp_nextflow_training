# Template for a static website using Sphinx and GitHub Pages

## Instructions

### 1. Create new repository based on this template

Create a template based on 
[this repository](https://github.com/enryH/notes_template)
by clicking on the "Use this template" button,
see instructions
[here](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template#creating-a-repository-from-a-template)

- now you are already publish the site which looks identical to the template site
 (see it here)
- jump to step 5 to do that directly.

### 2. Open in GitHub Codespaces (or locally)

- go to [github.com/codespaces](https://github.com/codespaces)
- create a new codespace using the forked repository

> If you are done, remember to delete the codespace to not see your free credit or money
> wasted. Also inactive (stopped) codespaces use storage for the last 30 days.

### 3. Edit files

You will need to know the Markdown to format your text. See 
[this overview on GitHub](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax) 
or [this cheatsheet](https://www.markdownguide.org/cheat-sheet/) to get started.

- update in `conf.py` at least the author, project and copyright information at the top
  - also update two urls to your repository:
   ```json
    "github_url": "https://github.com/enryh/",
    "repository_url": "https://github.com/enryh/notes_template",
    ```
- write something about you in `about.md`
- write articles in `folder_topic/article_topic.md`
- update the `index.md` file to include new files
- use [pandoc](https://pandoc.org/try/) to convert your previous files into markdown or
  reStructuredText

Troubleshooting:
 - don't forget to add new files to the `index.md` file
 - each document should have a title (`# title`) using a main heading and otherwise 
   nested headlines (subheadings followed by sub-subheadings)

### 4. Build the site locally

Sphinx uses the configuration file `conf.py` to set up the site. The `requirements.txt` file
contain extensions and themes that are used additionally to sphinx to build the site.
The layout of the website is defined in the `index.md` file.

> Have look at `.github/workflows/build_website.yaml` to see how the site is built
> if you are interested.

- Open a terminal (GitHub Codespaces)
- install required packages from [`requirements.txt`](requirements.txt):
  ```bash
  pip install -r requirements.txt
  ```
- build the site (you could set an alias if you want):
  ```bash
  sphinx-build -n -W --keep-going -b html ./ ./_build/
  ```
  in case the command is not found, try:
  ```bash
   python -m sphinx -n -W --keep-going -b html ./ ./_build/
  ```
- open the site in a browser:
  - install ["Live Preview" extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.live-server) in Visual Studio Code
  - open the `_build/index.html` file in the browser (right-click, "Show Preview")

### 5. Publish the site

Follow 
[these instructions](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site) 
to publish the website using GitHub Pages.

- Select the `gh-pages` branch as the source for the GitHub Pages site (currently step 7)
- add the deployed url to your "About" on the right sight of the repository
