function Try_jsDoc_from_the_Command_Line_A() {

  pushd ~/${PARENT_DIR}/${PROJECT_NAME}/ >/dev/null;

  echo -e "\n\nBefore generating documentation . . . "
  tree -L 2 ./packages/${PKG_NAME}
  jsdoc -d ./packages/${PKG_NAME}/docs ./packages/${PKG_NAME}
  echo -e "\n\n . . . after generating documentation . . . "
  tree -L 2 ./packages/${PKG_NAME}

  popd >/dev/null;

}


function Try_jsDoc_from_the_Command_Line_B() {

  echo "Paste this URI into your browser :"
  echo -e "\n   file://${HOME}/${PARENT_DIR}/${PROJECT_NAME}/packages/${PKG_NAME}/docs/index.html\n\n"

}


function Use_Sublime_Text_jsDoc_plugin_A() {

  pushd ~/${PARENT_DIR}/${PROJECT_NAME}/packages/${PKG_NAME} >/dev/null;

  wget -O ${PKG_NAME}-tests.js https://raw.githubusercontent.com/martinhbramwell/Meteor-CI-Tutorial/master/fragments/package-tests_T05_05.js

  popd >/dev/null;

}


function Use_Sublime_Text_jsDoc_plugin_B() {

  pushd ~/${PARENT_DIR}/${PROJECT_NAME}/packages/${PKG_NAME} >/dev/null;

  wget -O ${PKG_NAME}-tests.js https://raw.githubusercontent.com/martinhbramwell/Meteor-CI-Tutorial/master/fragments/package-tests_T05_06.js

  popd >/dev/null;

}


function Use_Sublime_Text_jsDoc_plugin_C() {

  pushd ~/${PARENT_DIR}/${PROJECT_NAME}/ >/dev/null;

  jsdoc -d ./packages/${PKG_NAME}/docs ./packages/${PKG_NAME}
  echo -e "\n Look at : ${HOME}/${PARENT_DIR}/${PROJECT_NAME}/packages/${PKG_NAME}/docs/index.html\n\n"

  popd >/dev/null;

}


TEMP_ZIP="/tmp/${PKG_NAME}_docs.zip";
function Publish_jsDocs_toGitHub_B() {

  pushd ~/${PARENT_DIR}/${PROJECT_NAME}/packages/${PKG_NAME} >/dev/null;

    pushd docs >/dev/null;

      echo -e "Zipping up the documentation directory.\n"

      rm -f ${TEMP_ZIP}
      zip -qr ${TEMP_ZIP} *

    popd >/dev/null;

    eval "$(ssh-agent -s)";

    set +e
    git add .eslintrc
    git add .eslintignore

    if [[ 1 -gt $(git status | grep -c "nothing to commit") ]]; then
      # git add docs/*
      echo -e "Committing master branch changes of the package.\n"

      # echo "git add errors : $?"
      git commit -am "Committing .eslintrc and related alterations."
      echo "git commit errors : $?"
      git push
      echo "git push errors : $?"
    fi;

    set -e

  popd >/dev/null;

  echo -e "Pushing to remote repo and publishing docs as a GitHub Pages website.\n"
  ./scripts/PushDocsToGitHubPagesBranch.sh \
              ${PKG_NAME} \
              ~/${PARENT_DIR}/${PROJECT_NAME}/packages/${PKG_NAME} \
              ${TEMP_ZIP} \
              ${PKG_NAME}_origin;

  echo -e "Removing temp file.\n"
  rm -f ${TEMP_ZIP}

  echo -e "To see your documentation on-line, wait a few minutes, then open this link:\n\n          https://${GITHUB_ORGANIZATION_NAME}.github.io/${PKG_NAME}/"

}
