#! /bin/bash
# Author: NSKevin
# Date: 2017.7.21

shellPath=$1
params=$2
COLOR_RED="\033[1;31m"
COLOR_GREEN="\033[0;36m"
COLOR_NORMAL="\033[0m"
COLOR_YELLOW="\033[0;33m"

##################################################
# Functions
##################################################

gitStatusCheck() {
  # Check The Status First (If you have code uncommit or unstaged, the console message will contain the tip <file>)
  if [[ `git status` =~ "<file>" ]]; then
    echo -e "${COLOR_YELLOW}=====================  Warning: You Have Uncommit Code In ${COLOR_GREEN}$1  ${COLOR_YELLOW}=====================${COLOR_NORMAL}"
    echo "Please Make A Choice For Your Operation :"
    echo "1. Stash the uncommit code "
    echo "2. Reset the uncommit code "
    echo "3. Commit the uncommit code"
    echo "4. Diff the uncommit code"
    read choice
    [[ $choice -eq 1 ]] && git stash
    [[ $choice -eq 2 ]] && (git add . && git reset --hard)
    [[ $choice -eq 3 ]] && (echo "Please Input Your Commit Message:" && read commitMsg && echo $commitMsg && git add . && git commit -m "$commitMsg")
    # Shell will be terminated after git diff so we recurse the func
    [[ $choice -eq 4 ]] && (git diff && gitStatusCheck $1)
    # Input Error And Recurse The Choice
    choiceArr=(1 2 3 4)
    [[ "${choiceArr[@]/$choice/}" == "${choiceArr[@]}" ]] && echo -e "${COLOR_RED}The Choice You Make Not In The List Please Try Again : )\n${COLOR_NORMAL}" && gitStatusCheck $1
  fi
}

dealWithGitJob() {
  currentPath=`pwd`
  [[ ${currentPath:-1} == "/" ]] && gitPath="`pwd`$1" || gitPath="`pwd`/$1"
  cd $gitPath
  # Check The Status First
  gitStatusCheck $1
  git pull
  echo -e "${COLOR_GREEN}=====================  Success: $1 =====================${COLOR_NORMAL}"
  cd $currentPath
}

##################################################
# Check Path
##################################################
cd $shellPath
[[ $? -ne 0 ]] && (echo -e "${COLOR_RED}=====================  Error: Invalid Parameter (Path)  =====================${COLOR_NORMAL}" && exit)

##################################################
# Get Podfile Path
##################################################
podfilePath="Podfile"
[[ ${1:-1} == "/" ]] && podfilePath="`pwd`Podfile" || podfilePath="`pwd`/Podfile"

##################################################
# Check Pod File
##################################################
[[ ! -f "$podfilePath" ]] && (echo -e "${COLOR_RED}===================== Error:  There's No Podfile In The Path You Input  =====================${COLOR_NORMAL}" && exit)

##################################################
# Get Local Develop Pod Name From Podfile
##################################################
podsContent=`egrep -i "^(\s+(pod)|(pod_one))[^#].*(:path)" $podfilePath`
linesOfPods=($podsContent)
podDir=[]
podIndex=0
for line in ${linesOfPods[*]}
do
  if [[ $line =~ ".podspec" ]]; then
    #translate / to \n then make it to an array
    podNameArray=(`echo $line | tr "/" "\n"`)
    podDir[podIndex]=${podNameArray[1]}
    podIndex=$[$podIndex + 1]
  fi
done

##################################################
# Loop The Pod Dirctory And Deal With Git Job
##################################################
for pod in ${podDir[*]}
do
  dealWithGitJob $pod
done

echo -e "\n${COLOR_GREEN}All Jobs Has Been Done! 🙂${COLOR_NORMAL}"
