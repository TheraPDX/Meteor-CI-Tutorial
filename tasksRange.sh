#!/bin/bash
#
TasksList="tasksList_A.sh";
SectionPrefix="Tutorial";
FileSuffix="_functions.sh";

RANGE_LIMITS=(

  "01|PrepareTheMachine|Java_7_is_required_by_Nightwatch_A|Got Java Installer|, but [ci skip].|"
  "10|AutomatedDeployment|PushFinalChanges|Pushing latest changes to GitHub for rebuild on CircleCI.||"

);

StartExecuting="${RANGE_LIMITS[0]}";
StopExecuting="${RANGE_LIMITS[1]}";

START_SECTION=$(echo ${StartExecuting} | cut -f1 -d"|");
export SUDO_REQUIRED=1;
if [[ ${START_SECTION#0} -eq 1 ]]; then
  CRP=$(sudo pwd);
fi;