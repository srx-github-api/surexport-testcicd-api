#!/bin/bash
for i in "$@"; do
  case $1 in
    --client-id=*)
      CLIENT_ID="${i#*=}"
      shift
      ;;
    --client-secret=*)
      CLIENT_SECRET="${i#*=}"
      shift
      ;;
    --application-name=*)
      APPLICATION_NAME="${i#*=}"
      shift
      ;;
    --environment=*)
      ENVIRONMENT="${i#*=}"
      shift
      ;;
    --workers=*)
      WORKERS="${i#*=}"
      shift
      ;;
    --worker-type=*)
      WORKER_TYPE="${i#*=}"
      shift
      ;;
    --env=*)
      ENV="${i#*=}"
      shift
      ;;
    --encrypt-key=*)
      ENCRYPT_KEY="${i#*=}"
      shift
      ;;
    -*|--*|*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

INVALID_ARGUMENTS=0
if [ -z $CLIENT_ID ]
then
  printf "ERROR: --client-id argument required\n"
  INVALID_ARGUMENTS=1
fi
if [ -z $CLIENT_SECRET ]
then
  printf "ERROR: --client-secret argument required\n"
  INVALID_ARGUMENTS=1
fi
if [ -z $APPLICATION_NAME ]
then
  printf "ERROR: --application-name argument required\n"
  INVALID_ARGUMENTS=1
fi
if [ -z $ENVIRONMENT ]
then
  printf "ERROR: --environment argument required\n"
  INVALID_ARGUMENTS=1
fi
if [ -z $ENV ]
then
  printf "ERROR: --env argument required\n"
  INVALID_ARGUMENTS=1
fi
if [ -z $ENCRYPT_KEY ]
then
  printf "ERROR: --encrypt-key argument required\n"
  INVALID_ARGUMENTS=1
fi

if [ $INVALID_ARGUMENTS -eq 1 ]
then
  exit 1
fi

if [ -z $WORKERS ]
then
  WORKERS=1
  printf "INFO: <default-value> --workers 1\n"
fi
if [ -z $WORKER_TYPE ]
then
  WORKER_TYPE=MICRO
  printf "INFO: <default-value> --worker-type MICRO\n"
fi

OAUTH_TOKEN="$(curl -s --location --request POST https://anypoint.mulesoft.com/accounts/api/v2/oauth2/token --header "Content-Type: application/x-www-form-urlencoded" --data-urlencode "client_id=$CLIENT_ID" --data-urlencode "client_secret=$CLIENT_SECRET" --data-urlencode "grant_type=client_credentials" | grep -oP '(?<="access_token":")[^"]*')"
APPLICATION_NAME="$APPLICATION_NAME"-"$ENV"
mvn deploy -DmuleDeploy -DattachMuleSources -DauthToken=${OAUTH_TOKEN} -Dcloudhub.environment=${ENVIRONMENT} -Dcloudhub.application.name=${APPLICATION_NAME} -Ddeployment.workers=${WORKERS} -Ddeployment.worker.type=${WORKER_TYPE} -Denv=${ENV} -DencryptKey=${ENCRYPT_KEY}
