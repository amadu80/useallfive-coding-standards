## Introduction

This is a simple bash script to help install UseAllFive's coding standard rules and the dependencies needed to apply these rules in a Git Pre-commit hook.

## Dependencies

While this script tries to install as many of the dependencies as possible, there are a few that it can not handle on its own and need to be handled externally.  They are:

* **Node.js** - To install this simply visit, http://nodejs.org/, download and run the installation script

## Usage

To install all dependencies and the git pre-commit hook, simply run the following from the root directory of your git repository:
```bash
sudo ./install.sh -a
```

If you would like to only install certain components, then you have the
following options:

### PEAR
PEAR is the PHP Extension and Application Repository (http://pear.php.net/). This is a dependency of PHP_CodeSniffer.
```bash
sudo ./install.sh --install-pear
```

### PHP_CodeSniffer
[PHP_CodeSniffer](http://pear.php.net/package/PHP_CodeSniffer) tokenises PHP, JavaScript and CSS files and detects violations of a defined set of coding standards.  Successful installation of this package depends on PEAR being installed.
```bash
sudo ./install.sh --install-php_codesniffer
```

### JSHint
[JSHint](http://jshint.com/) is a community-driven tool to detect errors and potential problems in JavaScript code and to enforce your team's coding conventions. It is controlled by a `.jshintrc` file in your project's root directory.  Successful installation of this depends on node.js and npm being installed.
```bash
sudo ./install.sh --install-jshint
```

### Git Commit hook
This is a custom git pre-commit hook that depends on the above packages.  This command must be run from the root directory of the git repository you wish to install it to, and will abort if an existing pre-commit hook is present.
```bash
sudo ./install.sh --install-git-commit-hooks
```
