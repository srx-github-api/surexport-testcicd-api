#!/bin/bash
MAVEN_REPOSITORY_PATH=$HOME/.m2
if [ ! -d $MAVEN_REPOSITORY_PATH ]; then mkdir $MAVEN_REPOSITORY_PATH; fi
cp -f settings.xml $MAVEN_REPOSITORY_PATH/settings.xml	