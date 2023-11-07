#!/bin/bash

if [ -z "$GIT_REPO_URL" ]; then
  echo "GIT_REPO_URL is not set. Exiting."
  exit 1
fi

if [ -z "$ANTORA_PLAYBOOK" ]; then
  echo "ANTORA_PLAYBOOK not defined.  Falling back to ANTORA_PLAYBOOK=site.yml"
  ANTORA_PLAYBOOK="site.yml"
fi
# Setup working directory for cloning and rendering

# WORKDIR=/home/antora/repo
WORKDIR=/showroom/repo
#mkdir -p $WORKDIR

echo
echo "git clone the $GIT_REPO_URL into $WORKDIR"
git clone $GIT_REPO_URL $WORKDIR || cd $WORKDIR && git pull
cd $WORKDIR

# Extract the name of the repository to use as the working directory
# REPO_NAME=$(basename $GIT_REPO .git)

# Change working directory to cloned repository
# cd $REPO_NAME
#
# Download file with wget
# wget $URL

# Merge user_data.yml into component's antora.yml
# you'll have to mount the user_data.yaml into /showroom
# OpenShift will do it with a configMap

USER_DATA_FILE: "/user_data/user_data.yml"

echo "Original user_data in content/antora.yml"
cat $WORKDIR/content/antora.yml

if test -r ${USER_DATA_FILE}
then
  echo "NOW editing ${USER_DATA_FILE}"}
  yq -i '.asciidoc.attributes *= load("${USER_DATA_FILE}")' $WORKDIR/content/antora.yml
  echo "new user_data in content/antora.yml"
else
  echo "No ${USER_DATA_FILE} found."
fi
cat $WORKDIR/content/antora.yml
echo

# Run antora command (adjust the playbook file as needed)
echo "Run antora site.yml"
WWW_ROOT=/showroom/www/

test -d $WWW_ROOT || mkdir $WWW_ROOT

antora --to-dir=$WWW_ROOT $ANTORA_PLAYBOOK

echo "Run httpd"
cd $WWW_ROOT
python3 -m http.server

# Additional commands or logic can be added here if needed