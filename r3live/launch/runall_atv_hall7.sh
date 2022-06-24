catkin build r3live ;
source /home/$USER/dev_ws/devel/setup.bash


# Get the current directory
CURR_DIR=$(pwd)
# Get the location of the viral package
roscd r3live
PACKAGE_DIR=$(pwd)
# Return to the current dir, print the directions
cd $CURR_DIR
echo CURRENT DIR: $CURR_DIR
echo VIRAL DIR:   $PACKAGE_DIR

export CAPTURE_SCREEN=false;
export LOG_DATA=true;

# use non-visual Loop
export DATASET_LOCATION=/media/$USER/mySataSSD3/ATVCollectedNoDepth
export EPOC_DIR=/media/$USER/KTHSSD/r3live_trident_20220602_livox

#region USE VIS, NO UWB -----------------------------------------------------------------------------------------------

for BAG_FILE in $DATASET_LOCATION/*.bag ;
do
(
    EXP_NAME=$(basename "$BAG_FILE" | sed 's/.bag//g')
    echo "Begin run with exp $EXP_NAME: "

    ./run_one_bag_atv_hall7.sh $EPOC_DIR $DATASET_LOCATION $PACKAGE_DIR $EXP_NAME $CAPTURE_SCREEN $LOG_DATA 450 1 0 1 0 0 0.75 -1;
)
done

#endregion USE VIS, NO UWB --------------------------------------------------------------------------------------------


# use non-visual Loop
export DATASET_LOCATION=/media/$USER/mySataSSD3/ATVCollectedNoDepth
export EPOC_DIR=/media/$USER/KTHSSD/r3live_trident_20220602_ouster

#region USE VIS, NO UWB -----------------------------------------------------------------------------------------------

for BAG_FILE in $DATASET_LOCATION/*.bag ;
do
(
    EXP_NAME=$(basename "$BAG_FILE" | sed 's/.bag//g')
    echo "Begin run with exp $EXP_NAME: "

    ./run_one_bag_atv_hall7_ouster.sh $EPOC_DIR $DATASET_LOCATION $PACKAGE_DIR $EXP_NAME $CAPTURE_SCREEN $LOG_DATA 450 1 0 1 0 0 0.75 -1;
)
done

#endregion USE VIS, NO UWB --------------------------------------------------------------------------------------------



#region ## Poweroff ---------------------------------------------------------------------------------------------------

# wait;
# shutdown +20;

#endregion ## Poweroff ------------------------------------------------------------------------------------------------