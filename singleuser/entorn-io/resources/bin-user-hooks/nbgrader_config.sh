#!/bin/bash

if [ -z "$COURSE_NAME" ]
then
      export COURSE_NAME=dev
fi

if [[ -z "$RESOURCES_PATH" ]]; then
                RESOURCES_PATH=/resources
fi


########### nbgrader config start #################

export COURSE_HOME_ON_CONTAINER="/home/$NB_USER/assignments/${COURSE_NAME}"

if [[ "${IS_INSTRUCTOR}" == "true" ]] ; then

  if [[ ! -f $COURSE_HOME_ON_CONTAINER/nbgrader_config.py ]]
  then
      mkdir -p $COURSE_HOME_ON_CONTAINER
      [ -f $RESOURCES_PATH/nbgrader/nbgrader_config.py ] && cp $RESOURCES_PATH/nbgrader/nbgrader_config.py $COURSE_HOME_ON_CONTAINER/
      [ -d $RESOURCES_PATH/nbgrader/source ] && cp -r $RESOURCES_PATH/nbgrader/source $COURSE_HOME_ON_CONTAINER/
      chown -R $NB_USER:$NB_GROUP /home/$NB_USER/assignments
  fi
  if [[ ! -f /home/${NB_USER}/.jupyter/nbgrader_config.py ]]
  then
      echo "c = get_config()" > /home/${NB_USER}/.jupyter/nbgrader_config.py
      echo "import os" >> /home/${NB_USER}/.jupyter/nbgrader_config.py
      echo "c.CourseDirectory.root = os.environ['COURSE_HOME_ON_CONTAINER']" >> /home/${NB_USER}/.jupyter/nbgrader_config.py
      chown $NB_USER:$NB_GROUP /home/${NB_USER}/.jupyter/nbgrader_config.py
  fi
  alias ngshare-course-management=ng
fi
############### nbgrader config end #######################
