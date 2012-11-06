#!/bin/bash

EXIT_BAD_ARG=1

RETURN_SUCCESS=0

while getopts ":a-:" opt; do
  case "$opt" in
    a)
      INSTALL_GIT_COMMIT_HOOKS=true
      INSTALL_JSHINT=true
      INSTALL_PEAR=true
      INSTALL_PHP_CODESNIFFER=true
      ;;
    -)
        case "${OPTARG}" in
          install-git-commit-hooks)
            INSTALL_GIT_COMMIT_HOOKS=true
            ;;
          install-jshint)
            INSTALL_JSHINT=true
            ;;
          install-pear)
            INSTALL_PEAR=true
            ;;
          install-php_codesniffer)
            INSTALL_PHP_CODESNIFFER=true
            ;;
        esac
        ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit $EXIT_BAD_ARG
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

function main {
  dep_check

  if [ ${INSTALL_PEAR} ]; then
    pear_install
  fi

  if [ ${INSTALL_PHP_CODESNIFFER} ]; then
    php_codesniffer_install
  fi

  if [ ${INSTALL_JSHINT} ]; then
    jshint_install
  fi

  if [ ${INSTALL_GIT_COMMIT_HOOKS} ]; then
    git_commit_hooks_install
  fi
}

#-- Color codes
txtred="$(tput setaf 1)" # Red
txtgrn="$(tput setaf 2)" # Green
txtrst="$(tput sgr0) "   # Text Reset


#----------------------#
#-- Helper Functions --#
#----------------------#

function error {
  echo -e "\n\n${txtred}== ERROR: $1${txtrst}\n"
  exit $2
}

function is_installed {
  which $1 2>&1 >/dev/null
  return $?
}

function progress {
  echo -e "${txtgrn}==${txtrst} $1"
}

vercomp () {
  #-- Frome: http://stackoverflow.com/questions/4023830/bash-how-compare-two-strings-in-version-format
  if [[ $1 == $2 ]]; then
    return 0
  fi
  local IFS=.
  local i ver1=($1) ver2=($2)
  # fill empty fields in ver1 with zeros
  for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
    ver1[i]=0
  done
  for ((i=0; i<${#ver1[@]}; i++)); do
    if [[ -z ${ver2[i]} ]]; then
      # fill empty fields in ver2 with zeros
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]})); then
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 2
    fi
  done
  return 0
}

#---------------#
#-- Functions --#
#---------------#

function dep_check {
  REQUIRED_PROGS="git php node npm"
  for prog in $REQUIRED_PROGS; do
    is_installed "$prog"
    if [ 0 -ne $? ]; then
      error "Could not locate $prog" $EXIT_MISSING_DEP
    fi
  done
}


#--
#-- pear
#--

function pear_install {
  local ret

  #-- Check if pear is in the PATH
  is_installed pear
  ret=$?

  if [ 0 -ne $ret ]; then
    #-- check for the full path
    if [ -d "$(pear_get_dir)" -a -x "$(pear_get_dir)/bin/pear" ]; then
      ret=0
    fi
  fi

  if [ 0 -eq $ret ]; then
    progress "pear is already installed.  Skipping."
  else
    #-- Download
    progress "Downloading PEAR"
    curl -O http://pear.php.net/go-pear.phar
    if [ 0 -ne $? ]; then
      error "Could not download PEAR installer." $EXIT_PEAR_DOWNLOAD_ERR
    fi

    #-- Install
    progress "Installing PEAR"
    php go-pear.phar
    if [ 0 -ne $? ]; then
      error "Could not install PEAR installer." $EXIT_PEAR_INSTALL_ERR
    fi

    #-- Cleanup
    rm go-pear.phar
  fi
}

function pear_get_dir {
  DIRS="$HOME/pear /usr/lib/php/pear /usr/share/pear"
  for dir in $DIRS; do
    if [ -d "$dir" ]; then
      echo $dir
      return $RETURN_SUCCESS
    fi
  done
  error "Could not locate pear directory" $EXIT_PEAR_NO_DIR
}


#--
#-- PHP_CodeSniffer
#--
function php_codesniffer_install {
  local ret
  local pear_bin

  #-- Install the program
  progress "Installing PHP_CodeSniffer"
  is_installed pear
  if [ 0 -eq $? ]; then
    pear_bin="pear"
  elif [ -x $(pear_get_dir)/bin/pear ]; then
    pear_bin="$(pear_get_dir)/bin/pear"
  else
    error "Could not locate pear executable. Exiting"  $EXIT_PEAR_NO_BIN
  fi
  $pear_bin install PHP_CodeSniffer

  #-- Install the PHP_Codesniffer-VariableAnalysis ruleset
  progress "Installing PHP_Codesniffer-VariableAnalysis Ruleset"
  if [ -d "PHP_Codesniffer-VariableAnalysis" ]; then
    if [ -d "PHP_Codesniffer-VariableAnalysis/.git" ]; then
      cd PHP_Codesniffer-VariableAnalysis
      git pull
      ret=$?
      cd ..
    else
      error "Directory 'PHP_Codesniffer-VariableAnalysis' already exists but is not a git clone. Exiting" $EXIT_PHPCS_ERR
    fi
  else
    git clone https://github.com/illusori/PHP_Codesniffer-VariableAnalysis
    ret=$?
  fi
  if [ 0 -eq $ret ]; then
    cd PHP_Codesniffer-VariableAnalysis
    ./install.sh -d "$(pear_get_dir)/share/pear/PHP/CodeSniffer"
    if [ 0 -ne $? ]; then
      error "Could not install 'PHP_Codesniffer-VariableAnalysis'. Exiting" $EXIT_PHPCS_ERR
    fi
    cd ..
    rm -rf PHP_Codesniffer-VariableAnalysis
  else
    error "Could not locate 'PHP_Codesniffer-VariableAnalysis' install files. Exiting" $EXIT_PHPCS_ERR
  fi

  #-- Install the UseAllFive
  progress "Installing UseAllFive Ruleset"
  git clone https://github.com/UseAllFive/useallfive-coding-standards.git
  local cs_dir="`find $(pear_get_dir) -type d -name CodeSniffer | grep 'PHP/CodeSniffer'`"
  cp -r "useallfive-coding-standards/PHP_CodeSniffer/Standards/UseAllFive" "${cs_dir}/Standards"
  rm -rf "useallfive-coding-standards"
}


#--
#-- UseAllFive Git Commit Hooks
#--
function git_commit_hooks_install {
  local dst
  local f

  progress "Installing UseAllFive Commit Hooks"

  #-- Check that git is at least 1.7.7 (for --include-untracked support)
  local git_ver=`git --version | sed -nEe's/git version ([0-9\.]+).*/\1/p'`
  vercomp $git_ver "1.7.7"
  if [ 2 -eq $? ]; then
    error "git version 1.7.7+ is required.  Exiting." $EXIT_MISSING_DEP
  fi

  #-- Make sure we are in a git repositor
  if [ ! -d .git ]; then
    error "UseAllFive Git Commit hooks can only be installed from the root git directory" $EXIT_UA5_GIT_HOOKS_ERR
  fi
  git clone https://github.com/UseAllFive/useallfive-coding-standards.git
  cd "useallfive-coding-standards/git_commit_hooks"
  for f in *; do
    dst="../../.git/hooks/${f}"
    if [ -f "${dst}" ]; then
      cd "../.."
      rm -rf "useallfive-coding-standards"
      error "'${PWD}/${dst}' already exists.  Exiting." $EXIT_UA5_GIT_HOOKS_ERR
    else
      cp "${f}" "${dst}"
    fi
  done
  cd "../.."
  rm -rf "useallfive-coding-standards"
}


#--
#-- JSHint
#--
function jshint_install {
  #-- Check if jshint is in the PATH
  is_installed jshint
  ret=$?

  if [ 0 -eq $ret ]; then
    progress "jshint is already installed.  Skipping."
  else
    progress "Installing jshint"
    npm install -g jshint
    if [ 0 -ne $? ]; then
      error "Could not install jshint." $EXIT_JSHINT_INSTALL_ERR
    fi
  fi
}

#-- Finally execute the main function
main
