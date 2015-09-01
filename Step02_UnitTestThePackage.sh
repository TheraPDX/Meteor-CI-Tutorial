#!/bin/bash
#
if [[ $EUID -eq 0 ]]; then
   echo -e "This script SHOULD NOT be run with 'sudo' (as root). "
   exit 1
fi

DOCS="./UnitTestThePackage/doc"
source ./explain.sh

function existingMeteor() {

  EXISTING_METEOR_PID=$(ps aux | grep meteor | grep tools/main.js | awk '{print $2}')
  if [[  ${EXISTING_METEOR_PID} -gt 0  ]]; then
    echo ""
    echo ""
    echo "A Meteor process was started earlier.  Find it and stop it."
    echo "If you cannot find it, in a separate terminal window, stop it now with :"
    echo "   kill -9 ${EXISTING_METEOR_PID}"
    echo ""
    echo -e "After you have stopped the old Meteor process hit <enter> to start the new one.  "
    read -n 1 -r USER_ANSWER
  fi

}

highlight ${DOCS}/Introduction.md
read -p "Hit <enter> ::  " -n 1 -r USER_ANSWER

AUTORUN=a
explain ${DOCS}/Set_Up_Project_Names.md
AUTORUN=
if ! getUserData; then
    echo -e "#####################################################################"
    echo -e "#   The rest of this script will fail without correct values for : "
    echo -e "#    - project name"
    echo -e "#    - project owner name"
    echo -e "#    - project owner email."
    echo -e "#   Please ensure you have entered these values correctly."
    echo -e "#####################################################################"
    exit 1;
fi;



explain ${DOCS}/Configure_git_for_GitHub.md # CODE_BLOCK
if [ $? -eq 0 ]; then

  echo -e "#   -- Configuring git ... "

  git config --global user.email "${YOUR_NAME}"
  git config --global user.name "${YOUR_EMAIL}"
  git config --global push.default simple

fi

AUTORUN="";


explain ${DOCS}/Create_SSH_keys_directory_if_not_exist.md # CODE_BLOCK
if [ $? -eq 0 ]; then
  SET_UP_SSH=true;
  if [ -f ~/.ssh/id_rsa ]; then SET_UP_SSH=false;  fi
  if [ -f ~/.ssh/id_rsa.pub ]; then SET_UP_SSH=false;  fi
  if [ -f ~/.ssh/authorized_keys ]; then SET_UP_SSH=false;  fi

  if [ ${SET_UP_SSH} == true ]; then
    echo "Setting up SSH directory";
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    touch ~/.ssh/authorized_keys                               #  Edit to add allowed connections
    touch ~/.ssh/id_rsa                                        #  Edit to add private key
    touch ~/.ssh/id_rsa.pub                                    #  Edit to add public key
    chmod 600 ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/id_rsa
    chmod 644 ~/.ssh/id_rsa.pub
    ls -la ~/.ssh

    echo -e "#########################################################################################"
    echo -e "#   The necessary files have been created and permissions set correctly."
    echo -e "#   Please provide the correct content for the three files listed above"
    echo -e "#########################################################################################"
    read -p "Hit <enter> ::  " -n 1 -r USER_ANSWER

  else
    echo -e "#########################################################################################"
    echo -e "#   Found SSH artifacts already present.  Will NOT set up SSH."
    echo -e "#   Please ensure you have a correctly configured SSH directory for use with GitHub."
    echo -e "#   Visit :  https://help.github.com/articles/generating-ssh-keys/"
    echo -e "#########################################################################################"
  fi
fi



explain ${DOCS}/Install_Meteor.md # CODE_BLOCK
if [ $? -eq 0 ]; then
  INSTALLMETEOR=true
  if [[ $(meteor --version) =~ .*Meteor.* ]]
  then
    echo "Meteor has been installed already.  Do you want to reinstall?"
    read -p "  'y' or 'n' ::  " -n 1 -r USER_ANSWER
    CHOICE=$(echo ${USER_ANSWER:0:1} | tr '[:upper:]' '[:lower:]')
    if [[ "X${CHOICE}X" == "XnX" ]];
    then
      INSTALLMETEOR=false;
    fi;
  fi

  if ${INSTALLMETEOR}; then curl https://install.meteor.com/ | sh; fi;

fi




export PARENT_DIR=projects
METEOR_PORT=3000


explain ${DOCS}/Create_Meteor_project.md # CODE_BLOCK
if [ $? -eq 0 ]; then
  # Make a projects directory
  mkdir -p ~/${PARENT_DIR}

  pushd ~/${PARENT_DIR}


  BUILD_IT=true
  if [[ -d ~/${PARENT_DIR}/${PROJECT_NAME} ]]; then
    echo "";
    echo "";
    echo "The project, '${PROJECT_NAME}', was created earlier.
            You can delete it and [r]ecreate it OR [s]kip this step."
    read -p "  'r' or 's' ::  " -n 1 -r USER_ANSWER
    CHOICE=$(echo ${USER_ANSWER:0:1} | tr '[:upper:]' '[:lower:]')
    if [[ "X${CHOICE}X" == "XsX" ]]; then
      BUILD_IT=false
    else
      echo "";
      echo "Deleting old ${PROJECT_NAME}. . . ";
      rm -fr ${PROJECT_NAME}
    fi;
    echo ""
  fi

  if ${BUILD_IT}; then

    echo "creating project ${PROJECT_NAME} . . . ";
    # Start a Meteor project
    meteor create ${PROJECT_NAME}

  else
    echo "Skipped";
  fi

  ls -la ${PROJECT_NAME}
  popd


fi



explain ${DOCS}/Check_the_meteor_project_will_work.md # CODE_BLOCK
if [ $? -eq 0 ]; then

  existingMeteor

  pushd ~/${PARENT_DIR}/${PROJECT_NAME}

  meteor &

  echo -e "#########################################################################################"
  echo -e "#   Meteor is now starting up as a background process."
  echo -e "#   In a browser, please open the URL -- http://localhost:${METEOR_PORT}/ --"
  echo -e "#    to confirm that it is working."
  echo -e "#########################################################################################"
  echo -e "After you have confirmed that Meteor is working on port ${METEOR_PORT} hit <enter> to STOP IT and go on to next step.  "
  read -n 1 -r USER_ANSWER

  echo -e "Stopping Meteor process . . . "

  kill -9 $(jobs -p)

  popd

fi


export GITHUB_RAW="https://raw.githubusercontent.com/warehouseman/meteor-swagger-client/master/.eslintrc"
explain ${DOCS}/Add_Meteor_application_development_support_files.md # CODE_BLOCK
if [ $? -eq 0 ]; then

  pushd ~/${PARENT_DIR}
  pushd ${PROJECT_NAME}

  cat << LICMIT > LICENSE
The MIT License (MIT)

Copyright (c) 2015 Warehouseman

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICMIT

  cat << GITIG > .gitignore
.meteor/local
.meteor/meteorite
GITIG

  cat << RDME > README.md
# ${PROJECT_NAME}

A bare minimum app and package for running TinyTest and NightWatch in CircleCI
RDME

  wget -N https://raw.githubusercontent.com/warehouseman/meteor-swagger-client/master/.eslintrc
  # wget -N https://raw.githubusercontent.com/airbnb/javascript/master/packages/eslint-config-airbnb/.eslintrc
  # wget -N https://raw.githubusercontent.com/meteor/meteor/devel/scripts/admin/eslint/.eslintrc

  ls -la

  popd
  popd

fi

echo ""
echo ""
highlight ${DOCS}/Configure_Sublime_Text_to_use_ESLint.md
read -p "To continue hit <enter> ::  " -n 1 -r USER_ANSWER

echo ""
echo ""
highlight ${DOCS}/Create_remote_GitHub_repository.md
read -p "To continue hit <enter> ::  " -n 1 -r USER_ANSWER


explain ${DOCS}/Create_local_GitHub_repository.md # CODE_BLOCK
if [ $? -eq 0 ]; then

  pushd ~/${PARENT_DIR}
  pushd ${PROJECT_NAME}

  git init
  git add .
  git commit -am 'First commit'
  git remote add origin git@github.com:${GITHUB_ORGANIZATION_NAME}/${PROJECT_NAME}.git
  # git remote set-url origin git@github.com:FleetingClouds/${PROJECT_NAME}.git
  git push -u origin master

  popd
  popd

fi




explain ${DOCS}/Create_a_package_and_TinyTest_it.md # CODE_BLOCK
if [ $? -eq 0 ]; then

  existingMeteor

  pushd ~/${PARENT_DIR}
  pushd ${PROJECT_NAME}

  meteor create --package yours:skeleton
  meteor test-packages &

  tree

  echo -e "#########################################################################################"
  echo -e "#   Meteor Package Testing is now starting up as a background process."
  echo -e "#   In a browser, please open the URL -- http://localhost:${METEOR_PORT}/ --"
  echo -e "#    to confirm that it is working."
  echo -e "#    "
  echo -e "#   Above, you can see the files that were created."
  echo -e "#    "
  echo -e "#########################################################################################"
  echo -e "Hit <enter> after you have confirmed that Meteor ran successful tests ::  "
  read -n 1 -r USER_ANSWER

  kill -9 $(jobs -p)

  popd
  popd

fi



explain ${DOCS}/Add_a_test_runner_for_getting_TinyTest_output_on_the_command_line.md # CODE_BLOCK
if [ $? -eq 0 ]; then

  existingMeteor

  pushd ~/${PARENT_DIR}
  pushd ${PROJECT_NAME}

  wget -N https://raw.githubusercontent.com/warehouseman/meteor-tinytest-runner/master/meteor-tinytest-runner.run
  chmod ug+x meteor-tinytest-runner.run
  sudo chown -R ${USER}:${USER} ~/.npm
  ./meteor-tinytest-runner.run
  ./tests/tinyTests/test-all.sh
  echo -e "#########################################################################################"
  echo -e "#   Above you should see lines like :"
  echo -e "#   [INFO] http://127.0.0.1:4096/packages/test-in-console.js?59dde1f. . . 07b3f499 75:17 S: tinytest - example "
  echo -e "#    "
  echo -e "#   and below, after you hit <enter>, you should see the new list of project files. "
  echo -e "#    "
  echo -e "#########################################################################################"
  echo -e "Hit <enter> after you have confirmed that Meteor ran successful tests ::  "
  read -n 1 -r USER_ANSWER
  tree

  popd
  popd

fi



explain ${DOCS}/Add_a_CircleCI_configuration_file_and_push_to_GitHub.md # CODE_BLOCK
if [ $? -eq 0 ]; then

  pushd ~/${PARENT_DIR}
  pushd ${PROJECT_NAME}

  mv example_circle.yml circle.yml

  git add packages
  git add circle.yml
  git add tests
  git commit -am 'Added package and package testing'
  git push -u origin master

  echo -e "#########################################################################################"
  echo -e "#   Open your CircleCI site and explore the most recent build.  In the build section you "
  echo -e "#   should find the same lines as before when we ran the test runner locally : "
  echo -e "#   [INFO] http://127.0.0.1:4096/packages/test-in-console.js?59dde1f. . . 07b3f499 75:17 S: tinytest - example "
  echo -e "#    "
  echo -e "#   Notice the execution time. Rebuild, and notice how the test is faster thanks to "
  echo -e "#   caching of dependencies"
  echo -e "#########################################################################################"
  echo -e "Hit <enter> after you have confirmed that CircleCI ran successful tests ::  "
  read -n 1 -r USER_ANSWER
  popd
  popd

fi




explain ${DOCS}/Prepare_for_NightWatch_testing.md # CODE_BLOCK
if [ $? -eq 0 ]; then

  pushd ~/${PARENT_DIR}
  pushd ${PROJECT_NAME}

  wget -N https://github.com/warehouseman/meteor-nightwatch-runner/raw/master/meteor-nightwatch-runner.run
  chmod ug+x meteor-nightwatch-runner.run

  ./meteor-nightwatch-runner.run
  popd
  popd

fi


explain ${DOCS}/Run_NightWatch_testing.md # CODE_BLOCK
if [ $? -eq 0 ]; then

  existingMeteor

  pushd ~/${PARENT_DIR}
  pushd ${PROJECT_NAME}

  meteor &  #  Running meteor in the background
  ./tests/nightwatch/runTests.js | bunyan
  kill -9 $(jobs -p)

  echo -e "#########################################################################################"
  echo -e "#   You ought to see lines similar to these : "
  echo -e "#  "
  echo -e "#   [2015-08-16T16:26:46.081Z]  INFO: demo/11123 on PkgTestDemo: Running:  Layout and Static Pages"
  echo -e "#   [2015-08-16T16:26:51.343Z]  INFO: demo/11123 on PkgTestDemo: ✔ Testing if element <body> is present."
  echo -e "#   [2015-08-16T16:26:51.934Z]  INFO: demo/11123 on PkgTestDemo: OK. 1 assertions passed. (5.851s)"
  echo -e "#   [2015-08-16T16:26:51.936Z]  INFO: demo/11123 on PkgTestDemo: "
  echo -e "#   [2015-08-16T16:26:51.936Z]  INFO: demo/11123 on PkgTestDemo: OK. 1 assertion passed. (6.554s)"
  echo -e "#   [2015-08-16T16:26:52.253Z]  INFO: demo/11123 on PkgTestDemo: Finished!  Nightwatch ran all the tests!"
  echo -e "#    "
  echo -e "#########################################################################################"
  echo -e "Hit <enter> after you have confirmed that you have these results ::  "
  read -n 1 -r USER_ANSWER
  popd
  popd

fi



explain ${DOCS}/Push_Nightwatch_testing_to_GitHub_and_CircleCI.md # CODE_BLOCK
if [ $? -eq 0 ]; then

  pushd ~/${PARENT_DIR}
  pushd ${PROJECT_NAME}

  cp tests/nightwatch/config/example_circle.yml circle.yml

  git add tests/nightwatch
  git commit -am 'Added Nightwatch testing'
  git push -u origin master

  popd
  popd

fi


echo ""
echo ""
highlight ${DOCS}/Observe_ordinary_console_logging.md
read -p "To continue hit <enter> ::  " -n 1 -r USER_ANSWER

echo ""
echo ""
highlight ${DOCS}/Add_an_NPM_module_to_your_package.md
read -p "To continue hit <enter> ::  " -n 1 -r USER_ANSWER

echo ""
echo ""
highlight ${DOCS}/Specify_Npm_modules.md
read -p "To continue hit <enter> ::  " -n 1 -r USER_ANSWER

echo ""
echo ""
highlight ${DOCS}/dummy.md
read -p "To continue hit <enter> ::  " -n 1 -r USER_ANSWER

echo ""
echo ""
highlight ${DOCS}/dummy.md
read -p "To continue hit <enter> ::  " -n 1 -r USER_ANSWER


# echo ""
# echo ""
# highlight ${DOCS}/dummy.md
# read -p "To continue hit <enter> ::  " -n 1 -r USER_ANSWER




echo -e "\nDone.";
exit 0;

# explain "#  FIXME
# \n#
# \n#
# \n#  "
# if [ $? -eq 0 ]; then

#   pushd ~/${PARENT_DIR}
#   pushd ${PROJECT_NAME}


#   popd
#   popd

# fi


echo "Done.";
exit 0;