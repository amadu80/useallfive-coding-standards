## UseAllFive Coding Standards

This is a simple bash script to help install UseAllFive's coding standard rules and the dependencies needed to apply these rules in a Git Pre-commit hook.

## [Dependencies](https://github.com/ner0tic/useallfive-coding-standards/blob/master/doc/01-dependencies.md)
While this script tries to install as many of the dependencies as possible, there are a few that it can not handle on its own and need to be handled externally.  

## Usage

To install all dependencies and the git pre-commit hook, simply run the following replacing `/path/to/repository` with your own:
```bash
sudo ./install_hooks.sh /path/to/repository
```

### [Configuration Files](https://github.com/ner0tic/useallfive-coding-standards/blob/master/docs/03-configuration-files.md)
These files can be copied into your project's root directory to configure the related tools to use these defaults.

### [PHP_CodeSniffer](http://pear.php.net/package/PHP_CodeSniffer) 
Tokenizes PHP, JavaScript and CSS files and detects violations of a defined set of coding standards.  Successful installation of this package depends on PEAR being installed.

### [JSHint](http://jshint.com/) 
A community-driven tool to detect errors and potential problems in JavaScript code and to enforce your team's coding conventions. It is controlled by a `.jshintrc` file in your project's root directory.  Successful installation of this depends on node.js and npm being installed.

### [Git Commit hook](https://github.com/ner0tic/useallfive-coding-standards/blob/master/doc/02-pre-commit.md)
This is a custom git pre-commit hook that depends on the above packages.  This command must be run from the root directory of the git repository you wish to install it to, and will abort if an existing pre-commit hook is present.
