#!/bin/bash
#

source ./scripts/util.sh;

declare -a TUTSPATHS=();
declare -a FILEPATHS=();
function assembleMapsOfDirectoryAndFileNames() {
  for filename in ./Tutorial*.sh; do
    PT=$(echo ${filename} | sed 's/.\///g' | sed 's/_/_|/g' | sed 's/.sh/|/g');
    TUTSPATH=$(echo ${filename} | sed 's/.\///g' | sed 's/.sh//g');
    echo "${PT}   ºº   ${TUTSPATH}";
    TUTSPATHS+=(${TUTSPATH});
    while read -r line; do
      FN=$(echo "${line}" | sed 's/\.md.*/.md/g');
      FN=$(echo "${FN}" | sed 's/.*BINDIR}\///g');
      FN=$(echo "${FN}" | sed 's/.md//g');
  #    echo -e "Processing the file :: ${PT}${FN}\n";
  #    ls -l ${PT}/${FN}.*;
      FILEPATHS+=("${PT}${FN}");
    done < <(grep -E 'explain.*BINDIR|BINDIR.*explain'  ${filename})
  done

}

function deleteAllPreviouslyConcatenatedMarkdownFiles() {
  for idx_d in "${TUTSPATHS[@]}"
  do
    # ls -l ${idx_d}/concatenatedSlides.MD
    rm -f ${idx_d}/concatenatedSlides.MD
  done
}

function applyManualVsAutomaticIndicator() {

  SKIP_INTRO="Introduction.md";
  SKIP_END="Fin.md";
  if [ "${AFP/${SKIP_INTRO}}" = "${AFP}" ] ; then
    if [ "${AFP/${SKIP_END}}" = "${AFP}" ] ; then
      LNUM=$(grep -nr "${FPA[2]}.*MANUAL_INPUT_REQUIRED" ${SCRIPT_FILE}  | cut -d : -f 1);
      PATTERN='input_type_indicator';
      if [[ "${LNUM}" -gt 0 ]]; then
        REPLACEMENT='  <br \/><br \/><div class="input_type_indicator"><img src=".\/fragments\/typer.gif" \/><br \/>Manual input is required here.<\/div><br \/>';
#        REPLACEMENT='Manual input'
      else
        REPLACEMENT='  <br \/><br \/><div class="input_type_indicator"><img src=".\/fragments\/loader.gif" \/><br \/>No manual input required here.<\/div><br \/>';
#        REPLACEMENT='No manual input'
      fi
      sed -i "s/.*${PATTERN}.*/${REPLACEMENT}/g" ${AFP};
      echo "${AFP} does ${REPLACEMENT}"
    fi
  fi

}

function substituteFieldsInSlide() {

  FUNCTIONS_FILE="${SCRIPT_FILE_NAME}/${FPA[1]}_functions.sh";
#  FUNCTIONS_FILE="${FPA[0]}${FPA[1]}/${FPA[1]}_functions.sh";
#  ls -l ${FUNCTIONS_FILE};
  readarray -t LNUMS <<<"$(grep -nr ${FPA[2]} ${FUNCTIONS_FILE}  | cut -d : -f 1)"
  echo "FPA :: |- ${FPA[0]} -|- ${FPA[1]} -|- ${FPA[2]} -|- ${LNUMS[0]} -|";
  LNUM=${LNUMS[0]};
  if [[ "${LNUM}" -gt 0 ]]; then

    DBGLOG=false;
    if [[ "${FPA[1]}" == "VersionControlInTheCloud" && "${LNUM}" -lt 1  || "${LNUM}" -eq 999 ]]; then
      DBGLOG=true;
    fi;

    ${DBGLOG} && echo -e "\n\n ${FUNCTIONS_FILE}, Line number : ${LNUM}":

    export PATTERN='<!-- B -->]';
    ${DBGLOG} && echo "Old : ${PATTERN}";
    export CODE_URL="${GITHUB_DIR}${FUNCTIONS_FILE}#L${LNUM}";
    export REPLACEMENT='<!-- B -->';
    REPLACEMENT+='\n.center[.footnote[.red.bold[] <a href="';
    REPLACEMENT+="${CODE_URL}";
    REPLACEMENT+='" target="_blank">Code for this step.</a>] ]';
    REPLACEMENT+='\n]';

    ${DBGLOG} && echo "New : ${REPLACEMENT}";
    ${DBGLOG} && ls -l "${AFP}";
    ${DBGLOG} && echo "# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";

    sed -i "0,/${PATTERN}/s|${PATTERN}|${REPLACEMENT}|" ${AFP};

#    sed -i "0,/<!-- B -->]/s|<!-- B -->]|<!-- B -->\n***\n]|" Tutorial02_VersionControlInTheCloud/Create_local_GitHub_repository.md

    export PATTERN='#L[0-9]*'
#    echo "Old : ${PATTERN}"
    export REPLACEMENT="#L${LNUM}"
    ${DBGLOG} && echo "New : ${REPLACEMENT}"
    sed -i "0,/${PATTERN}/s|${PATTERN}|${REPLACEMENT}|" ${AFP}

  #     export PATTERN='begins at line #[0-9]*'
  #     ${DBGLOG} && echo "Old : ${PATTERN}"
  #     export REPLACEMENT="begins at line #${LNUM}"
  #     ${DBGLOG} && echo "New : ${REPLACEMENT}"
  #     sed -i "0,/${PATTERN}/s|${PATTERN}|${REPLACEMENT}|" ${AFP}
  # #
    export PATTERN='blob\/master\/[A-Za-z0-9_]*.sh'
#    echo "Old : ${PATTERN}"
    export REPLACEMENT="blob/master/${FUNCTIONS_FILE}"
    ${DBGLOG} && echo "New : ${REPLACEMENT}"
    sed -i "0,/${PATTERN}/s|${PATTERN}|${REPLACEMENT}|" ${AFP}

  fi;


}

SKIP=true;
if [[ "X$1X" == "XyX" ]]; then
  SKIP=false;
elif [[ "X$1X" != "XnX" ]]; then
  echo -e ""
  echo -e "Usage : "
  echo -e " - '$0 y' generate documentation and commit to gh-pages branch"
  echo -e " - '$0 n' generate documentation only"
  echo -e ""
  echo -e "Hit '<enter>' to generate documentation without commit"
  echo -e "Hit 'y' now to generate documentation and commit to gh-pages branch"
  echo -e "Hit 'q' to quit"
  read -p " 'y', 'q' or '<enter>' ::  " -n 1 -r USER_ANSWER
  CHOICE=$(echo ${USER_ANSWER:0:1} | tr '[:upper:]' '[:lower:]')
  echo ""
  if [ "X${CHOICE}X" == "XqX" ]; then exit 0; fi;
  if [ "X${CHOICE}X" == "XyX" ]; then SKIP=false; fi;
fi;

assembleMapsOfDirectoryAndFileNames;

deleteAllPreviouslyConcatenatedMarkdownFiles;

#
# Process all markdown documents extracting just what a script user needs to see
#
GITHUB_DIR="https://github.com/martinhbramwell/Meteor-CI-Tutorial/blob/master/"
for idx_d in "${FILEPATHS[@]}"
do
  FP="${idx_d}";
  FPA=(${FP//|/ });
#  echo "FPA :: |- ${FPA[0]} -|- ${FPA[1]} -|- ${FPA[2]}";
  AFP="${FPA[0]}${FPA[1]}/${FPA[2]}.md"; # The complete path of the markdown file.
#  ls -l ${AFP};
  SCRIPT_FILE_NAME="${FPA[0]}${FPA[1]}";
  SCRIPT_FILE="${SCRIPT_FILE_NAME}.sh" # The name of the end user script
#  ls -l ${SCRIPT_FILE};
  # # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # #    Find line number of relevant code and add hyperlink at bottom of slide
  # #    Expect a flag "CODEBLOCK", otherwise skip this file, and check the next one..
  LCNT=$(grep -cr "${FPA[2]}.*CODE_BLOCK" ${SCRIPT_FILE});
  case "${LCNT}" in

  0)  # echo  "Slide with no code.";
      ;;
  2)  echo -e "\n\n\n    ${flashingRed}* * * * You have duplicate calls to explain * * * *${endColor} \n\n\n.";
      exit;
      ;;
  1)  # echo  "Slide with fields to substitute.";
      substituteFieldsInSlide ;
      ;;
  *) echo "This can't happen!"
     ;;
  esac

  applyManualVsAutomaticIndicator;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  cat ${AFP} >> ${FPA[0]}${FPA[1]}/concatenatedSlides.MD
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



done

exit;

if  ${SKIP} ;  then  exit 0; fi;

git log -1 --pretty=%B > gitlog.txt

tar zcvf pack.tar.gz index.html \
styles.css \
gitlog.txt \
fragments/typer.gif \
fragments/loader.gif \
PrepareTheMachine/concatenatedSlides.MD \
VersionControlInTheCloud/concatenatedSlides.MD \
UnitTestAPackage/concatenatedSlides.MD \
CodingStyleAndLinting/concatenatedSlides.MD \
AutomaticDocumentationInTheCloud/concatenatedSlides.MD \
CloudContinuousIntegration/concatenatedSlides.MD \
ProductionLogging/concatenatedSlides.MD \
RealWorldPackage/concatenatedSlides.MD \
PackageSelfTest/concatenatedSlides.MD


export STASH_CREATED=$(git stash) && echo $STASH_CREATED
if [[ "${STASH_CREATED}" != "No local changes to save" ]];
then
  echo ""
  echo "Changes to master branch have been stashed"
fi;
git checkout gh-pages
echo "On branch gh-pages"
tar zxvf pack.tar.gz
rm -f pack.tar.gz
MSG=$(cat gitlog.txt)
echo "Add anything new"
git add .
echo "Unpacked all."
git commit -am "${MSG}"
echo "Committed"
git push
echo "Pushed"
git checkout master
echo "- - - back on branch master - - -"
if [[ "${STASH_CREATED}" != "No local changes to save" ]];
then
  git stash apply;
  echo "Reverted stash"
else
  echo "No stash to restore";
fi;



